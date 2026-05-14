const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'dev-jwt-secret';

function requireAuth(req, res) {
  const header = req.headers.authorization || '';
  const token = header.replace('Bearer ', '');
  
  if (!token) {
    res.status(401).json({ success: false, error: 'Unauthorized: No token provided' });
    return false;
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    return true;
  } catch (err) {
    res.status(401).json({ success: false, error: 'Unauthorized: Invalid or expired token' });
    return false;
  }
}

function generateToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: '1y' });
}

module.exports = { requireAuth, generateToken };
