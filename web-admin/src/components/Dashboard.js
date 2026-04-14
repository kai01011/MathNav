import React, { useState, useEffect } from 'react';
import { signOut } from 'firebase/auth';
import { collection, getDocs, deleteDoc } from 'firebase/firestore';
import { auth, db } from '../firebase';
import QuizManagement from './QuizManagement';
import ProgressMonitor from './ProgressMonitor';
import UserManagement from './UserManagement';
import './Dashboard.css';

function Dashboard() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState('overview');
  const [cleanupLoading, setCleanupLoading] = useState(false);
  const [cleanupMessage, setCleanupMessage] = useState('');
  const [syncLoading, setSyncLoading] = useState(false);

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const querySnapshot = await getDocs(collection(db, 'users'));
      const usersList = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setUsers(usersList);
    } catch (error) {
      console.error('Error fetching users:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = async () => {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Error logging out:', error);
    }
  };

  const handleSyncQuizzes = async () => {
    setSyncLoading(true);
    setCleanupMessage('');

    try {
      const querySnapshot = await getDocs(collection(db, 'quizzes'));
      const count = querySnapshot.docs.length;
      
      const quizzesByQuarter = {
        1: 0,
        2: 0,
        3: 0,
        4: 0
      };
      
      querySnapshot.docs.forEach(doc => {
        const data = doc.data();
        if (data.quarter) {
          quizzesByQuarter[data.quarter]++;
        }
      });

      const breakdown = Object.entries(quizzesByQuarter)
        .map(([q, c]) => `Q${q}: ${c}`)
        .join(', ');

      setCleanupMessage(`Successfully synced! Found ${count} quizzes in Firebase (${breakdown}). All quizzes are available in the mobile app.`);
    } catch (error) {
      console.error('Error syncing quizzes:', error);
      setCleanupMessage('Error: ' + error.message);
    } finally {
      setSyncLoading(false);
    }
  };

  const handleClearAllQuizzes = async () => {
    if (!window.confirm('Are you sure you want to delete ALL quizzes? This action cannot be undone!')) {
      return;
    }

    setCleanupLoading(true);
    setCleanupMessage('');

    try {
      const querySnapshot = await getDocs(collection(db, 'quizzes'));
      const deletePromises = querySnapshot.docs.map(doc => deleteDoc(doc.ref));
      await Promise.all(deletePromises);
      setCleanupMessage(`Successfully deleted ${querySnapshot.docs.length} quizzes!`);
    } catch (error) {
      console.error('Error clearing quizzes:', error);
      setCleanupMessage('Error: ' + error.message);
    } finally {
      setCleanupLoading(false);
    }
  };

  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <h1>MathNav Admin Dashboard</h1>
        <div className="user-info">
          <span>{auth.currentUser?.email}</span>
          <button onClick={handleLogout}>Logout</button>
        </div>
      </header>

      <nav className="dashboard-nav">
        <button 
          className={activeTab === 'overview' ? 'active' : ''} 
          onClick={() => setActiveTab('overview')}
        >
          Overview
        </button>
        <button 
          className={activeTab === 'users' ? 'active' : ''} 
          onClick={() => setActiveTab('users')}
        >
          User Management
        </button>
        <button 
          className={activeTab === 'quizzes' ? 'active' : ''} 
          onClick={() => setActiveTab('quizzes')}
        >
          Quiz Management
        </button>
        <button 
          className={activeTab === 'progress' ? 'active' : ''} 
          onClick={() => setActiveTab('progress')}
        >
          Progress Monitor
        </button>
        <button 
          className={activeTab === 'cleanup' ? 'active' : ''} 
          onClick={() => setActiveTab('cleanup')}
        >
          Database Cleanup
        </button>
      </nav>

      <main className="dashboard-content">
        {activeTab === 'overview' && (
          <>
            <section className="stats">
              <div className="stat-card">
                <h3>Total Users</h3>
                <p className="stat-number">{users.length}</p>
              </div>
            </section>

            <section className="users-section">
              <h2>Users</h2>
              {loading ? (
                <p>Loading...</p>
              ) : (
                <table className="users-table">
                  <thead>
                    <tr>
                      <th>ID</th>
                      <th>Email</th>
                      <th>Created At</th>
                    </tr>
                  </thead>
                  <tbody>
                    {users.map(user => (
                      <tr key={user.id}>
                        <td>{user.id}</td>
                        <td>{user.email || 'N/A'}</td>
                        <td>{user.createdAt?.toDate?.()?.toLocaleDateString() || 'N/A'}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </section>
          </>
        )}

        {activeTab === 'quizzes' && <QuizManagement />}
        {activeTab === 'users' && <UserManagement />}
        {activeTab === 'progress' && <ProgressMonitor />}
        {activeTab === 'cleanup' && (
          <div className="cleanup-section">
            <h2>Database Management</h2>
            <p>Manage your quiz database and verify Firebase synchronization.</p>
            
            <div className="cleanup-actions">
              <button 
                className="btn-success" 
                onClick={handleSyncQuizzes}
                disabled={syncLoading}
              >
                {syncLoading ? 'Syncing...' : 'Sync & Verify Quizzes'}
              </button>
              
              <button 
                className="btn-danger" 
                onClick={handleClearAllQuizzes}
                disabled={cleanupLoading}
              >
                {cleanupLoading ? 'Deleting...' : 'Delete All Quizzes'}
              </button>
            </div>

            {cleanupMessage && (
              <div className={cleanupMessage.includes('Error') ? 'message-error' : 'message-success'}>
                {cleanupMessage}
              </div>
            )}
          </div>
        )}
      </main>
    </div>
  );
}

export default Dashboard;
