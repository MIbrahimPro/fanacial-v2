const pool = require('./_db');
const { requireAuth } = require('./_auth');

module.exports = async (req, res) => {
  if (!requireAuth(req, res)) return;
  res.setHeader('Content-Type', 'application/json');

  try {
    if (req.method === 'GET') {
      const { person_id } = req.query;
      let query = 'SELECT * FROM loans';
      const params = [];
      if (person_id) {
        query += ' WHERE person_id = $1';
        params.push(person_id);
      }
      query += ' ORDER BY date DESC';
      const result = await pool.query(query, params);
      return res.status(200).json({ success: true, data: result.rows });
    }

    if (req.method === 'POST') {
      const { id, person_id, amount, type, description, date, created_at, updated_at } = req.body;
      if (!id || !person_id || amount == null || !type || !date) {
        return res.status(400).json({ success: false, error: 'Missing required fields' });
      }
      const result = await pool.query(
        `INSERT INTO loans (id, person_id, amount, type, description, date, created_at, updated_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
         ON CONFLICT (id) DO UPDATE SET
           person_id=EXCLUDED.person_id, amount=EXCLUDED.amount, type=EXCLUDED.type,
           description=EXCLUDED.description, date=EXCLUDED.date, updated_at=EXCLUDED.updated_at
         RETURNING *`,
        [id, person_id, amount, type, description || null, date, created_at || new Date().toISOString(), updated_at || new Date().toISOString()]
      );
      return res.status(201).json({ success: true, data: result.rows[0] });
    }

    return res.status(405).json({ success: false, error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: err.message });
  }
};
