const pool = require('./_db');
const { requireAuth } = require('./_auth');

const TABLES = ['tags', 'people', 'transactions', 'stat_entries', 'loans'];

module.exports = async (req, res) => {
  if (!requireAuth(req, res)) return;

  if (req.method !== 'POST') {
    return res.status(405).json({ success: false, error: 'Method not allowed' });
  }

  res.setHeader('Content-Type', 'application/json');

  try {
    const { last_sync, records } = req.body;
    const conflicts = [];

    // --- PUSH phase ---
    if (records) {
      for (const table of TABLES) {
        const items = records[table];
        if (!items || !items.length) continue;

        for (const item of items) {
          if (item._deleted) {
            await pool.query(`DELETE FROM ${table} WHERE id = $1`, [item.id]);
            continue;
          }

          // Check if record exists on server
          const existing = await pool.query(`SELECT updated_at FROM ${table} WHERE id = $1`, [item.id]);

          if (existing.rows.length === 0) {
            // Server doesn't have it — INSERT
            await _upsert(table, item, pool);
          } else {
            // Compare timestamps
            const serverUpdated = new Date(existing.rows[0].updated_at).getTime();
            const clientUpdated = new Date(item.updated_at).getTime();

            if (clientUpdated > serverUpdated) {
              // Client is newer — UPDATE
              await _upsert(table, item, pool);
            } else if (clientUpdated < serverUpdated) {
              // Server is newer — CONFLICT (server wins)
              conflicts.push({ id: item.id, table, reason: 'server_newer' });
            }
            // Equal timestamps — skip
          }
        }
      }
    }

    // --- PULL phase ---
    const pullData = {};
    for (const table of TABLES) {
      const result = last_sync
        ? await pool.query(
            `SELECT * FROM ${table} WHERE updated_at > $1 ORDER BY updated_at ASC`,
            [last_sync]
          )
        : await pool.query(`SELECT * FROM ${table} ORDER BY updated_at ASC`);
      pullData[table] = result.rows;
    }

    const nowResult = await pool.query('SELECT NOW() AS sync_time');

    return res.status(200).json({
      success: true,
      data: pullData,
      conflicts,
      sync_time: nowResult.rows[0].sync_time,
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, error: err.message });
  }
};

async function _upsert(table, item, pool) {
  const columns = Object.keys(item).filter(k => k !== '_deleted');
  const values = columns.map(c => item[c]);
  const placeholders = columns.map((_, i) => `$${i + 1}`).join(', ');
  const updates = columns.map(c => `${c}=EXCLUDED.${c}`).join(', ');

  await pool.query(
    `INSERT INTO ${table} (${columns.join(', ')})
     VALUES (${placeholders})
     ON CONFLICT (id) DO UPDATE SET ${updates}`,
    values
  );
}
