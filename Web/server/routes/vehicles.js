const express = require('express');
const router = express.Router();
const db = require('../firebase'); // Import Firestore instance

// POST /api/vehicles - Add a new vehicle
router.post('/', async (req, res) => {
  console.log('POST /api/vehicles called with body:', req.body); // Debug log
  const { number, type, length, width, name, facilities } = req.body;
  if (!number || !type || !length || !width || !name) {
    console.error('Validation failed: Missing required fields'); // Debug log
    return res.status(400).json({ error: 'All fields are required' });
  }
  try {
    const newVehicle = { number, type, length, width, name, facilities, createdAt: new Date().toISOString() };
    console.log('Saving vehicle to Firestore:', newVehicle); // Debug log
    const docRef = await db.collection('vehicles').add(newVehicle);
    console.log('Vehicle added with ID:', docRef.id); // Debug log
    res.status(201).json({ id: docRef.id, ...newVehicle });
  } catch (error) {
    console.error('Error adding vehicle to Firestore:', error); // Debug log
    res.status(500).json({ error: 'Failed to add vehicle' });
  }
});

module.exports = router;
