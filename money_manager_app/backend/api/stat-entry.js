const pool = require('./_db');
const { requireAuth } = require('./_auth');

module.exports = async (req, res) => {
  if (!requireAuth(req, res)) return;
  res.setHeader('Content-Type', 'application/json');

  const id = req.url.split('/').filter(Boolean).pop();

  try {
    if (req.method === 'GET') {
      const result = await pool.query('SELECT * FROM stat_entries WHERE id = $1', [id]);
      if (result.rows.length === 0) return res.status(404).json({ success: false, error: 'Not found' });
      return res.status(200).json({ success: true, data: result.rows[0] });
    }

    if (req.method === 'PUT') {
      const { card_type, name, amount, updated_at } = req.body;
      const result = await pool.query(
        `UPDATE stat_entries SET card_type=$1, name=$2, amount=$3, updated_at=$4 WHERE id=$5 RETURNING *`,
        [card_type, name, amount, updated_at || new Date().toISOString(), id]
      );
      if (result.rows.length === 0) return res.status(404).json({ success: false, error: 'Not found' });
      return res.status(200).json({ success: true, data: result.rows[0] });
    }

    if (req.method === 'DELETE') {
      const result = await pool.query('DELETE FROM stat_entries WHERE id = $1 RETURNING id', [id]);
      if (result.rows.length === 0) return res.status(404).json({ success: false, error: 'Not found' });
      return res.status(200).json({ success: true, data: { id } });
    }

    return res.status(405).json({ success: false, error: 'Method not allowed' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: err.message });
  }
};
