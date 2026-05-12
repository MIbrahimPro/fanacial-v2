const pool = require('./_db');
const { requireAuth } = require('./_auth');

module.exports = async (req, res) => {
  if (!requireAuth(req, res)) return;

  res.setHeader('Content-Type', 'application/json');

  try {
    if (req.method === 'GET') {
      const { updated_since } = req.query;
      let query = 'SELECT * FROM transactions';
      const params = [];
      if (updated_since) {
        query += ' WHERE updated_at > $1';
        params.push(updated_since);
      }
      query += ' ORDER BY date ASC';
      const result = await pool.query(query, params);
      return res.status(200).json({ success: true, data: result.rows });
    }

    if (req.method === 'POST') {
      const { id, type, name, description, amount, tag_id, date, created_at, updated_at } = req.body;
      if (!id || !type || !name || amount == null || !tag_id || !date) {
        return res.status(400).json({ success: false, error: 'Missing required fields' });
      }
      const result = await pool.query(
        `INSERT INTO transactions (id, type, name, description, amount, tag_id, date, created_at, updated_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
         ON CONFLICT (id) DO UPDATE SET
           type=EXCLUDED.type, name=EXCLUDED.name, description=EXCLUDED.description,
           amount=EXCLUDED.amount, tag_id=EXCLUDED.tag_id, date=EXCLUDED.date,
           updated_at=EXCLUDED.updated_at
         RETURNING *`,
        [id, type, name, description || null, amount, tag_id, date, created_at || new Date().toISOString(), updated_at || new Date().toISOString()]
      );
      return res.status(201).json({ success: true, data: result.rows[0] });
    }

    return res.status(405).json({ success: false, error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: err.message });
  }
};
