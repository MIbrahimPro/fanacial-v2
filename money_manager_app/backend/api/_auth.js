const API_SECRET = process.env.API_SECRET || 'dev-secret';

function requireAuth(req, res) {
  const header = req.headers.authorization || '';
  const token = header.replace('Bearer ', '');
  if (!token || token !== API_SECRET) {
    res.status(401).json({ success: false, error: 'Unauthorized' });
    return false;
  }
  return true;
}

module.exports = { requireAuth };
