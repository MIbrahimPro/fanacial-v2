// Run this script to initialize/reset the database schema
// Usage: DATABASE_URL=postgresql://... node setup.js

const fs = require('fs');
const path = require('path');
const { Pool } = require('pg');

const DATABASE_URL = process.env.DATABASE_URL;
if (!DATABASE_URL) {
  console.error('Error: DATABASE_URL environment variable is required');
  console.error('Usage: DATABASE_URL=postgresql://... node setup.js');
  process.exit(1);
}

const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: { rejectUnauthorized: false },
});

async function main() {
  console.log('Connecting to database...');
  const sqlPath = path.join(__dirname, 'setup.sql');
  const sql = fs.readFileSync(sqlPath, 'utf8');

  console.log('Executing schema...');
  await pool.query(sql);

  console.log('Schema created successfully!');
  await pool.end();
}

main().catch((err) => {
  console.error('Failed to create schema:', err.message);
  process.exit(1);
});
