import React, { useState } from 'react';
import { seedQuizzes } from '../utils/seedQuizzes';
import './SeedData.css';

function SeedData() {
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  const handleSeed = async () => {
    if (!window.confirm('This will add sample quizzes to the database. Continue?')) {
      return;
    }

    setLoading(true);
    setMessage('');

    const result = await seedQuizzes();
    
    if (result.success) {
      setMessage(`✅ Successfully added ${result.count} sample quizzes!`);
    } else {
      setMessage(`❌ Error: ${result.error}`);
    }
    
    setLoading(false);
  };

  return (
    <div className="seed-data">
      <div className="seed-card">
        <h2>Database Setup</h2>
        <p>Click the button below to add sample quizzes to your database.</p>
        <p className="warning">⚠️ This is useful for initial setup and testing.</p>
        
        <button 
          onClick={handleSeed} 
          disabled={loading}
          className="seed-button"
        >
          {loading ? 'Adding Quizzes...' : 'Seed Sample Quizzes'}
        </button>
        
        {message && (
          <div className={`message ${message.includes('✅') ? 'success' : 'error'}`}>
            {message}
          </div>
        )}

        <div className="info-box">
          <h3>What will be added?</h3>
          <ul>
            <li>9 sample quizzes across all 4 quarters</li>
            <li>Various topics and difficulty levels</li>
            <li>Complete with explanations</li>
          </ul>
        </div>
      </div>
    </div>
  );
}

export default SeedData;
