const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Firebase Admin SDK
// You need to download your service account key from Firebase Console
// and place it in this directory as 'serviceAccountKey.json'
try {
  const serviceAccount = require('./serviceAccountKey.json');
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  
  console.log('Firebase Admin SDK initialized successfully');
} catch (error) {
  console.error('Error initializing Firebase Admin SDK:', error.message);
  console.log('\nPlease add your serviceAccountKey.json file to the web-admin-backend directory');
  console.log('   Download it from: Firebase Console > Project Settings > Service Accounts > Generate New Private Key\n');
}

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Admin backend is running' });
});

// Reset user password
app.post('/api/users/reset-password', async (req, res) => {
  try {
    const { uid, newPassword } = req.body;

    if (!uid || !newPassword) {
      return res.status(400).json({ 
        success: false, 
        error: 'UID and newPassword are required' 
      });
    }

    if (newPassword.length < 8) {
      return res.status(400).json({ 
        success: false, 
        error: 'Password must be at least 8 characters' 
      });
    }

    // Update user password using Admin SDK
    await admin.auth().updateUser(uid, {
      password: newPassword
    });

    console.log(`Password updated for user: ${uid}`);

    res.json({ 
      success: true, 
      message: 'Password updated successfully' 
    });

  } catch (error) {
    console.error('Error updating password:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Get user by email (to find UID)
app.post('/api/users/get-by-email', async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ 
        success: false, 
        error: 'Email is required' 
      });
    }

    const userRecord = await admin.auth().getUserByEmail(email);

    res.json({ 
      success: true, 
      uid: userRecord.uid,
      email: userRecord.email,
      displayName: userRecord.displayName
    });

  } catch (error) {
    console.error('Error getting user:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Delete user
app.post('/api/users/delete', async (req, res) => {
  try {
    const { uid } = req.body;

    if (!uid) {
      return res.status(400).json({ 
        success: false, 
        error: 'UID is required' 
      });
    }

    await admin.auth().deleteUser(uid);

    console.log(`User deleted: ${uid}`);

    res.json({ 
      success: true, 
      message: 'User deleted successfully' 
    });

  } catch (error) {
    console.error('Error deleting user:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// List all users (paginated)
app.get('/api/users/list', async (req, res) => {
  try {
    const maxResults = parseInt(req.query.limit) || 1000;
    const listUsersResult = await admin.auth().listUsers(maxResults);

    const users = listUsersResult.users.map(user => ({
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      disabled: user.disabled,
      metadata: {
        creationTime: user.metadata.creationTime,
        lastSignInTime: user.metadata.lastSignInTime
      }
    }));

    res.json({ 
      success: true, 
      users,
      count: users.length
    });

  } catch (error) {
    console.error('Error listing users:', error);
    res.status(500).json({ 
      success: false, 
      error: error.message 
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`\nAdmin Backend Server running on http://localhost:${PORT}`);
  console.log(`API endpoints available at http://localhost:${PORT}/api`);
  console.log(`\nMake sure to add your serviceAccountKey.json file!\n`);
});
