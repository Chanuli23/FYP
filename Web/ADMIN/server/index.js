const express = require('express');
const bodyParser = require('body-parser');
const admin = require('firebase-admin');
const cors = require('cors');
const app = express();
app.use(cors()); // Ensure this line is present and correctly configured
app.use(bodyParser.json());

// Initialize Firebase Admin SDK
const serviceAccount = require('./firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://drive-app-ec08e.firebaseio.com',
});

const db = admin.firestore();

// Start the server
const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

app.get('/api/tasks', async (req, res) => {
  const { route } = req.query;
  if (!route) {
    return res.status(400).json({ error: 'Route is required' });
  }
  try {
    const snapshot = await db.collection(`tasks_${route}`).get(); // Use route-specific collection
    const tasks = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(tasks);
  } catch (error) {
    console.error(`Error fetching tasks for route ${route}:`, error.message);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

app.post('/api/tasks', async (req, res) => {
  const { title, description, dueDate, route } = req.body;
  if (!title || !description || !dueDate || !route) {
    return res.status(400).json({ error: 'Task title, description, due date, and route are required' });
  }
  try {
    const newTask = { title, description, dueDate, createdAt: new Date().toISOString(), completed: false };
    const docRef = await db.collection(`tasks_${route}`).add(newTask); // Use route-specific collection
    res.status(201).json({ id: docRef.id, ...newTask });
  } catch (error) {
    console.error(`Error adding task to route ${route}:`, error.message);
    res.status(500).json({ error: 'Failed to add task' });
  }
});

app.get('/api/vehicles', async (req, res) => {
  try {
    const snapshot = await db.collection('vehicles').get();
    const vehicles = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(vehicles);
  } catch (error) {
    console.error('Error fetching vehicles:', error.message);
    res.status(500).json({ error: 'Failed to fetch vehicles' });
  }
});

app.post('/api/vehicles', async (req, res) => {
  const { number, length, width, height, weight, facilities, idealFor } = req.body;
  if (!number || !length || !width || !height || !weight || !idealFor) {
    console.error('Validation Error: Missing fields in request body');
    return res.status(400).json({ error: 'All fields are required' });
  }
  try {
    const newVehicle = { number, length, width, height, weight, facilities, idealFor };
    console.log('Attempting to add vehicle to Firestore:', newVehicle); // Debug log

    const docRef = await db.collection('vehicles').add(newVehicle);
    console.log('Vehicle added successfully with ID:', docRef.id); // Debug log

    res.status(201).json({ id: docRef.id, ...newVehicle });
  } catch (error) {
    console.error('Error adding vehicle to Firestore:', error.message);
    res.status(500).json({ error: 'Failed to add vehicle' });
  }
});

app.delete('/api/vehicles/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await db.collection('vehicles').doc(id).delete();
    res.status(200).json({ message: 'Vehicle deleted successfully' });
  } catch (error) {
    console.error('Error deleting vehicle:', error.message);
    res.status(500).json({ error: 'Failed to delete vehicle' });
  }
});

// Endpoint to fetch users
app.get('/api/users', async (req, res) => {
  try {
    console.log('Fetching users from Firestore...');
    const snapshot = await db.collection('users').get();
    if (snapshot.empty) {
      console.error('No users found in Firestore.');
      return res.status(404).json({ error: 'No users found' });
    }
    const users = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    console.log('Users fetched successfully:', users);
    res.status(200).json(users);
  } catch (error) {
    console.error('Error fetching users:', error.message);
    res.status(500).json({ error: 'Failed to fetch users' });
  }
});

// Endpoint to fetch routes dynamically based on collection names
app.get('/api/routes', async (req, res) => {
  try {
    console.log('Fetching route collections from Firestore...');
    const collections = await db.listCollections();
    const routeCollections = collections
      .map((collection) => collection.id)
      .filter((id) => id.startsWith('tasks_')) // Filter collections that start with "tasks_"
      .map((id) => ({ id, name: id.replace('tasks_', '') })); // Extract route names

    if (routeCollections.length === 0) {
      console.error('No route collections found in Firestore.');
      return res.status(404).json({ error: 'No routes found' });
    }

    console.log('Routes fetched successfully:', routeCollections);
    res.status(200).json(routeCollections);
  } catch (error) {
    console.error('Error fetching route collections:', error.message);
    res.status(500).json({ error: 'Failed to fetch routes' });
  }
});

app.post('/api/assignments', async (req, res) => {
  const { route, vehicle, driver } = req.body;
  if (!route || !vehicle || !driver) {
    return res.status(400).json({ error: 'Route, vehicle, and driver are required' });
  }
  try {
    const newAssignment = { route, vehicle, driver, assignedAt: new Date().toISOString() };
    const docRef = await db.collection('assignments').add(newAssignment);
    res.status(201).json({ id: docRef.id, ...newAssignment });
  } catch (error) {
    console.error('Error saving assignment:', error.message);
    res.status(500).json({ error: 'Failed to save assignment' });
  }
});

app.get('/api/assignments', async (req, res) => {
  const { route } = req.query;
  if (!route) {
    return res.status(400).json({ error: 'Route is required' });
  }
  try {
    console.log(`Fetching assignments for route: ${route}`);
    const snapshot = await db.collection('assignments').where('route', '==', route).get();
    if (snapshot.empty) {
      console.log('No assignments found for this route.');
      return res.status(200).json([]); // Return an empty array if no assignments are found
    }
    const assignments = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    console.log('Assignments fetched successfully:', assignments);
    res.status(200).json(assignments);
  } catch (error) {
    console.error('Error fetching assignments:', error.message);
    res.status(500).json({ error: 'Failed to fetch assignments' });
  }
});

// Update an assignment
app.put('/api/assignments/:id', async (req, res) => {
  const { id } = req.params;
  const { route, vehicle, driver } = req.body;

  if (!route || !vehicle || !driver) {
    return res.status(400).json({ error: 'Route, vehicle, and driver are required' });
  }

  try {
    const assignmentRef = db.collection('assignments').doc(id);
    const assignmentDoc = await assignmentRef.get();

    if (!assignmentDoc.exists) {
      return res.status(404).json({ error: 'Assignment not found' });
    }

    await assignmentRef.update({ route, vehicle, driver });
    const updatedAssignment = { id, route, vehicle, driver, ...assignmentDoc.data() };
    res.status(200).json(updatedAssignment);
  } catch (error) {
    console.error('Error updating assignment:', error.message);
    res.status(500).json({ error: 'Failed to update assignment' });
  }
});

// Delete an assignment
app.delete('/api/assignments/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const assignmentRef = db.collection('assignments').doc(id);
    const assignmentDoc = await assignmentRef.get();

    if (!assignmentDoc.exists) {
      return res.status(404).json({ error: 'Assignment not found' });
    }

    await assignmentRef.delete();
    res.status(200).json({ message: 'Assignment deleted successfully' });
  } catch (error) {
    console.error('Error deleting assignment:', error.message);
    res.status(500).json({ error: 'Failed to delete assignment' });
  }
});

// GLOBAL error catcher
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection:', reason);
  process.exit(1); // optional: exit after logging
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught Exception:', error);
  process.exit(1); // optional
});
