const pool = require('./_db');
const { generateToken } = require('./_auth');
const bcrypt = require('bcryptjs');

module.exports = async (req, res) => {
  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, error: 'Method not allowed' });
  }

  const { pin } = req.body;
  if (!pin) {
    return res.status(400).json({ success: false, error: 'PIN is required' });
  }

  try {
    const result = await pool.query('SELECT pin_hash FROM users LIMIT 1');
    if (result.rows.length === 0) {
      return res.status(404).json({ success: false, error: 'No user found' });
    }

    const { pin_hash } = result.rows[0];
    
    // Check if PIN matches. Since it's seeded as plain text '1965', we check both plain and hash for transition
    let isValid = false;
    if (pin_hash === pin) {
      isValid = true;
      // Update to hash for better security if it was plain
      const hashed = await bcrypt.hash(pin, 10);
      await pool.query('UPDATE users SET pin_hash = $1 WHERE pin_hash = $2', [hashed, pin]);
    } else {
      isValid = await bcrypt.compare(pin, pin_hash);
    }

    if (!isValid) {
      return res.status(401).json({ success: false, error: 'Invalid PIN' });
    }

    const token = generateToken({ sub: 'admin' });
    
    await pool.query('UPDATE users SET last_login = NOW()');

    res.json({ success: true, token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: 'Server error' });
  }
};
