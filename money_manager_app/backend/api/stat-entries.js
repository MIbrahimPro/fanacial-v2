const pool = require('./_db');
const { requireAuth } = require('./_auth');

module.exports = async (req, res) => {
  if (!requireAuth(req, res)) return;
  res.setHeader('Content-Type', 'application/json');

  try {
    if (req.method === 'GET') {
      const result = await pool.query('SELECT * FROM stat_entries ORDER BY created_at ASC');
      return res.status(200).json({ success: true, data: result.rows });
    }

    if (req.method === 'POST') {
      const { id, card_type, name, amount, created_at, updated_at } = req.body;
      if (!id || !card_type || !name || amount == null) {
        return res.status(400).json({ success: false, error: 'Missing required fields' });
      }
      const result = await pool.query(
        `INSERT INTO stat_entries (id, card_type, name, amount, created_at, updated_at)
         VALUES ($1,$2,$3,$4,$5,$6)
         ON CONFLICT (id) DO UPDATE SET
           card_type=EXCLUDED.card_type, name=EXCLUDED.name, amount=EXCLUDED.amount,
           updated_at=EXCLUDED.updated_at
         RETURNING *`,
        [id, card_type, name, amount, created_at || new Date().toISOString(), updated_at || new Date().toISOString()]
      );
      return res.status(201).json({ success: true, data: result.rows[0] });
    }

    return res.status(405).json({ success: false, error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: err.message });
  }
};
