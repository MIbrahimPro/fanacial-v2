const pool = require('./_db');
const { requireAuth } = require('./_auth');

module.exports = async (req, res) => {
  if (!requireAuth(req, res)) return;
  res.setHeader('Content-Type', 'application/json');

  try {
    if (req.method === 'GET') {
      const result = await pool.query('SELECT * FROM people ORDER BY name ASC');
      return res.status(200).json({ success: true, data: result.rows });
    }

    if (req.method === 'POST') {
      const { id, name, created_at, updated_at } = req.body;
      if (!id || !name) {
        return res.status(400).json({ success: false, error: 'Missing required fields' });
      }
      const result = await pool.query(
        `INSERT INTO people (id, name, created_at, updated_at)
         VALUES ($1,$2,$3,$4)
         ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, updated_at=EXCLUDED.updated_at
         RETURNING *`,
        [id, name, created_at || new Date().toISOString(), updated_at || new Date().toISOString()]
      );
      return res.status(201).json({ success: true, data: result.rows[0] });
    }

    return res.status(405).json({ success: false, error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: err.message });
  }
};
