const express = require('express');
const router = express.Router();
const db = require('../firebase'); // Import Firestore instance

// GET /api/tasks?route=<route> - Fetch tasks for a specific route
router.get('/', async (req, res) => {
  const { route } = req.query;
  if (!route) {
    return res.status(400).json({ error: 'Route is required' });
  }
  try {
    const snapshot = await db.collection(`tasks_${route}`).get(); // Use route-specific collection
    const tasks = snapshot.docs.map((doc) => ({ id: doc.id, ...doc.data() }));
    res.status(200).json(tasks);
  } catch (error) {
    console.error(`Error fetching tasks for route ${route}:`, error);
    res.status(500).json({ error: 'Failed to fetch tasks' });
  }
});

// POST /api/tasks - Add a new task to a specific route
router.post('/', async (req, res) => {
  console.log('Received task data:', req.body); // Debug log
  const { name, route } = req.body;
  
  if (!name || !route) {
    console.log('Missing fields:', { name, route }); // Debug log
    return res.status(400).json({ error: 'Task name and route are required' });
  }

  try {
    const newTask = {
      name,
      route,
      createdAt: new Date().toISOString(),
      completed: false
    };
    
    const docRef = await db.collection('tasks').add(newTask);
    console.log('Task added with ID:', docRef.id); // Debug log
    res.status(201).json({ id: docRef.id, ...newTask });
  } catch (error) {
    console.error('Error adding task:', error);
    res.status(500).json({ error: 'Failed to add task' });
  }
});

// DELETE /api/tasks/:id?route=<route> - Delete a task from a specific route
router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  const { route } = req.query;
  if (!route) {
    return res.status(400).json({ error: 'Route is required' });
  }
  try {
    await db.collection(`tasks_${route}`).doc(id).delete(); // Use route-specific collection
    res.status(200).json({ message: 'Task deleted successfully' });
  } catch (error) {
    console.error(`Error deleting task from route ${route}:`, error);
    res.status(500).json({ error: 'Failed to delete task' });
  }
});

module.exports = router;
