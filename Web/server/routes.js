// server/routes.js
const express = require('express');
const router = express.Router();

// Firebase Admin SDK
const { getFirestore } = require('firebase-admin/firestore');
const db = getFirestore();

// POST /api/routes - Save a route to Firestore
router.post('/api/routes', async (req, res) => {
  try {
    const route = req.body;
    const docRef = await db.collection('routes').add(route);
    res.status(201).json({ id: docRef.id });
  } catch (err) {
    res.status(500).json({ error: 'Failed to save route' });
  }
});

module.exports = router;