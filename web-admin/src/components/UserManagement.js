import React, { useState, useEffect } from 'react';
import { collection, getDocs, doc, deleteDoc } from 'firebase/firestore';
import { db } from '../firebase';
import './UserManagement.css';

function UserManagement() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedBatch, setSelectedBatch] = useState('All'); // Add batch filter
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [newPassword, setNewPassword] = useState('');

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const querySnapshot = await getDocs(collection(db, 'users'));
      const usersList = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setUsers(usersList);
    } catch (error) {
      console.error('Error fetching users:', error);
      setMessage('Error fetching users: ' + error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleForceResetPassword = (user) => {
    setSelectedUser(user);
    setNewPassword('');
    setShowPasswordModal(true);
  };

  const handleSetPassword = async () => {
    if (!newPassword || newPassword.length < 8) {
      setMessage('Error: Password must be at least 8 characters');
      return;
    }

    if (!window.confirm(`Set password for ${selectedUser.email}?\n\nIMPORTANT: You must provide this password to the user:\n${newPassword}`)) {
      return;
    }

    try {
      // First, get the user's UID from Firebase Auth
      const response = await fetch('http://localhost:3001/api/users/get-by-email', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email: selectedUser.email })
      });

      const userData = await response.json();

      if (!userData.success) {
        throw new Error(userData.error || 'Failed to get user UID');
      }

      // Now reset the password using the UID
      const resetResponse = await fetch('http://localhost:3001/api/users/reset-password', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ 
          uid: userData.uid, 
          newPassword: newPassword 
        })
      });

      const resetData = await resetResponse.json();

      if (!resetData.success) {
        throw new Error(resetData.error || 'Failed to reset password');
      }

      // Success!
      setMessage(`Password set successfully for ${selectedUser.email}\n\nIMPORTANT: Provide this password to the user:\n${newPassword}`);
      setShowPasswordModal(false);
      
      // Copy to clipboard
      navigator.clipboard.writeText(`Email: ${selectedUser.email}\nPassword: ${newPassword}`);
      alert(`Password set successfully!\n\nCredentials copied to clipboard:\nEmail: ${selectedUser.email}\nPassword: ${newPassword}\n\nPlease provide these credentials to the user.`);
      
      // Auto-dismiss success message after 5 seconds
      setTimeout(() => setMessage(''), 5000);
      
    } catch (error) {
      console.error('Error:', error);
      
      // Check if backend is not running
      if (error.message.includes('fetch') || error.message.includes('NetworkError')) {
        setMessage(`Error: Backend server not running!\n\nPlease start the backend server:\n1. Open terminal in web-admin-backend folder\n2. Run: npm install\n3. Run: npm start\n\nSee web-admin-backend/README.md for setup instructions.`);
      } else {
        setMessage(`Error: ${error.message}`);
      }
    }
  };

  const handleDeleteUser = async (userId, email) => {
    if (!window.confirm(`Are you sure you want to delete user ${email}? This action cannot be undone!`)) {
      return;
    }

    try {
      await deleteDoc(doc(db, 'users', userId));
      setMessage(`User ${email} deleted successfully`);
      fetchUsers(); // Refresh the list
      setTimeout(() => setMessage(''), 5000);
    } catch (error) {
      console.error('Error deleting user:', error);
      setMessage(`Error: ${error.message}`);
    }
  };

  const filteredUsers = users.filter(user => {
    // Search filter
    const matchesSearch = user.email?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.username?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      user.name?.toLowerCase().includes(searchTerm.toLowerCase());
    
    // Batch filter
    const matchesBatch = selectedBatch === 'All' || user.batch === selectedBatch;
    
    return matchesSearch && matchesBatch;
  });

  // Get unique batches from users for the dropdown
  const availableBatches = ['All', ...new Set(users.map(u => u.batch).filter(Boolean))].sort();

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
    } catch {
      return 'N/A';
    }
  };

  return (
    <div className="user-management">
      <div className="user-management-header">
        <h2>User Management</h2>
        <button className="btn-primary" onClick={fetchUsers}>
          Refresh
        </button>
      </div>

      {message && (
        <div className={message.includes('Error') ? 'message-error' : 'message-success'}>
          {message}
        </div>
      )}

      <div className="search-bar">
        <input
          type="text"
          placeholder="Search by email, username, or name..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="search-input"
        />
        <select
          value={selectedBatch}
          onChange={(e) => setSelectedBatch(e.target.value)}
          className="batch-filter"
        >
          {availableBatches.map(batch => (
            <option key={batch} value={batch}>
              {batch === 'All' ? 'All Batches' : `Batch ${batch}`}
            </option>
          ))}
        </select>
      </div>

      <div className="users-stats">
        <div className="stat-card">
          <h3>Total Users</h3>
          <p className="stat-number">{users.length}</p>
        </div>
        <div className="stat-card">
          <h3>Active Batch</h3>
          <p className="stat-number">{selectedBatch === 'All' ? 'All' : selectedBatch}</p>
        </div>
        <div className="stat-card">
          <h3>Filtered Results</h3>
          <p className="stat-number">{filteredUsers.length}</p>
        </div>
      </div>

      {loading ? (
        <div className="loading">Loading users...</div>
      ) : (
        <div className="users-table-container">
          <table className="users-table">
            <thead>
              <tr>
                <th>Email</th>
                <th>Username</th>
                <th>Name</th>
                <th>Grade</th>
                <th>Gender</th>
                <th>Batch</th>
                <th>Registered</th>
                <th>Last Login</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan="9" style={{ textAlign: 'center', padding: '20px' }}>
                    No users found
                  </td>
                </tr>
              ) : (
                filteredUsers.map(user => (
                  <tr key={user.id}>
                    <td>{user.email || 'N/A'}</td>
                    <td>{user.username || 'N/A'}</td>
                    <td>{user.name || 'N/A'}</td>
                    <td>{user.grade || 'N/A'}</td>
                    <td>{user.gender || 'N/A'}</td>
                    <td>{user.batch || 'N/A'}</td>
                    <td>{formatDate(user.registrationDate)}</td>
                    <td>{formatDate(user.lastLogin)}</td>
                    <td>
                      <div className="action-buttons">
                        <button
                          className="btn-edit"
                          onClick={() => handleForceResetPassword(user)}
                          title="Set password manually"
                        >
                          Set Password
                        </button>
                        <button
                          className="btn-delete"
                          onClick={() => handleDeleteUser(user.id, user.email)}
                          title="Delete user"
                        >
                          Delete
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* Password Modal */}
      {showPasswordModal && (
        <div className="modal-overlay" onClick={() => setShowPasswordModal(false)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h3>Set Password for {selectedUser?.email}</h3>
            <p className="modal-description">
              Enter a new password for this user. You will need to provide this password to the user directly.
            </p>
            
            <div className="form-group">
              <label>New Password:</label>
              <input
                type="text"
                value={newPassword}
                onChange={(e) => setNewPassword(e.target.value)}
                placeholder="Enter password (min 8 characters)"
                className="password-input"
                style={{ width: '100%' }}
              />
              <small>Password must be at least 8 characters</small>
            </div>

            <div className="warning-box">
              <strong>Important:</strong>
              <ul>
                <li>You must manually provide this password to the user</li>
                <li>Password will be set directly using Firebase Admin SDK</li>
                <li>Backend server must be running (web-admin-backend)</li>
                <li>Credentials will be copied to your clipboard</li>
              </ul>
            </div>

            <div className="modal-actions">
              <button 
                className="btn-secondary"
                onClick={() => setShowPasswordModal(false)}
              >
                Cancel
              </button>
              <button 
                className="btn-primary"
                onClick={handleSetPassword}
                disabled={newPassword.length < 8}
              >
                Set Password
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default UserManagement;
