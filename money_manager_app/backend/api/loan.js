const pool = require('./_db');
const { requireAuth } = require('./_auth');

module.exports = async (req, res) => {
  if (!requireAuth(req, res)) return;
  res.setHeader('Content-Type', 'application/json');

  const id = req.url.split('/').filter(Boolean).pop();

  try {
    if (req.method === 'GET') {
      const result = await pool.query('SELECT * FROM loans WHERE id = $1', [id]);
      if (result.rows.length === 0) return res.status(404).json({ success: false, error: 'Not found' });
      return res.status(200).json({ success: true, data: result.rows[0] });
    }

    if (req.method === 'PUT') {
      const { person_id, amount, type, description, date, updated_at } = req.body;
      const result = await pool.query(
        `UPDATE loans SET person_id=$1, amount=$2, type=$3, description=$4, date=$5, updated_at=$6 WHERE id=$7 RETURNING *`,
        [person_id, amount, type, description || null, date, updated_at || new Date().toISOString(), id]
      );
      if (result.rows.length === 0) return res.status(404).json({ success: false, error: 'Not found' });
      return res.status(200).json({ success: true, data: result.rows[0] });
    }

    if (req.method === 'DELETE') {
      const result = await pool.query('DELETE FROM loans WHERE id = $1 RETURNING id', [id]);
      if (result.rows.length === 0) return res.status(404).json({ success: false, error: 'Not found' });
      return res.status(200).json({ success: true, data: { id } });
    }

    return res.status(405).json({ success: false, error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: err.message });
  }
};
