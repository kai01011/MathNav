import React, { useState, useEffect } from 'react';
import { collection, getDocs, query, orderBy } from 'firebase/firestore';
import { db } from '../firebase';
import './ProgressMonitor.css';

function ProgressMonitor() {
  const [progress, setProgress] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedQuarter, setSelectedQuarter] = useState('all');
  const [selectedStudent, setSelectedStudent] = useState('all');
  const [selectedTopic, setSelectedTopic] = useState('all');
  const [stats, setStats] = useState({
    totalAttempts: 0,
    averageScore: 0,
    topicPerformance: {},
    studentScores: {}
  });

  useEffect(() => {
    fetchProgress();
  }, []);

  const fetchProgress = async () => {
    try {
      const q = query(collection(db, 'progress'), orderBy('completedAt', 'desc'));
      const querySnapshot = await getDocs(q);
      const progressList = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data(),
        completedAt: doc.data().completedAt?.toDate()
      }));
      
      setProgress(progressList);
      calculateStats(progressList);
    } catch (error) {
      console.error('Error fetching progress:', error);
    } finally {
      setLoading(false);
    }
  };

  const calculateStats = (progressData) => {
    if (progressData.length === 0) {
      setStats({ totalAttempts: 0, averageScore: 0, topicPerformance: {}, studentScores: {} });
      return;
    }

    const totalAttempts = progressData.length;
    const totalScore = progressData.reduce((sum, p) => sum + (p.score || 0), 0);
    const averageScore = (totalScore / totalAttempts).toFixed(1);

    // Topic performance
    const topicPerformance = {};
    progressData.forEach(p => {
      if (!topicPerformance[p.topic]) {
        topicPerformance[p.topic] = { total: 0, count: 0 };
      }
      topicPerformance[p.topic].total += p.score || 0;
      topicPerformance[p.topic].count += 1;
    });

    Object.keys(topicPerformance).forEach(topic => {
      const perf = topicPerformance[topic];
      perf.average = (perf.total / perf.count).toFixed(1);
    });

    // Student scores - Auto sum per student
    const studentScores = {};
    progressData.forEach(p => {
      const email = p.studentEmail || 'Anonymous';
      if (!studentScores[email]) {
        studentScores[email] = {
          totalScore: 0,
          attempts: 0,
          quizzes: [],
          quarters: new Set()
        };
      }
      studentScores[email].totalScore += p.score || 0;
      studentScores[email].attempts += 1;
      studentScores[email].quizzes.push({
        topic: p.topic,
        quarter: p.quarter,
        score: p.score,
        date: p.completedAt
      });
      studentScores[email].quarters.add(p.quarter);
    });

    // Calculate average per student
    Object.keys(studentScores).forEach(email => {
      const student = studentScores[email];
      student.averageScore = (student.totalScore / student.attempts).toFixed(1);
      student.quarters = Array.from(student.quarters).sort();
    });

    setStats({ totalAttempts, averageScore, topicPerformance, studentScores });
  };

  const filteredProgress = progress.filter(p => {
    const quarterMatch = selectedQuarter === 'all' || p.quarter === parseInt(selectedQuarter);
    const studentMatch = selectedStudent === 'all' || p.studentEmail === selectedStudent;
    const topicMatch = selectedTopic === 'all' || p.topic === selectedTopic;
    return quarterMatch && studentMatch && topicMatch;
  });

  const uniqueTopics = [...new Set(progress.map(p => p.topic))].filter(Boolean).sort();

  const getQuarterStats = (quarter) => {
    const quarterProgress = progress.filter(p => p.quarter === quarter);
    if (quarterProgress.length === 0) return { attempts: 0, avg: 0 };
    
    const total = quarterProgress.reduce((sum, p) => sum + (p.score || 0), 0);
    return {
      attempts: quarterProgress.length,
      avg: (total / quarterProgress.length).toFixed(1)
    };
  };

  const uniqueStudents = [...new Set(progress.map(p => p.studentEmail))].filter(Boolean);

  return (
    <div className="progress-monitor">
      <h2>Student Progress Monitor</h2>

      <div className="stats-overview">
        <div className="stat-box">
          <h3>Total Attempts</h3>
          <p className="stat-number">{stats.totalAttempts}</p>
        </div>
        <div className="stat-box">
          <h3>Average Score</h3>
          <p className="stat-number">{stats.averageScore}%</p>
        </div>
        <div className="stat-box">
          <h3>Total Students</h3>
          <p className="stat-number">{Object.keys(stats.studentScores).length}</p>
        </div>
        <div className="stat-box">
          <h3>Topics Covered</h3>
          <p className="stat-number">{Object.keys(stats.topicPerformance).length}</p>
        </div>
      </div>

      {/* Student Summary Cards */}
      <div className="student-summary">
        <h3>Student Performance Summary</h3>
        <div className="student-cards">
          {Object.entries(stats.studentScores).map(([email, data]) => (
            <div key={email} className="student-card">
              <div className="student-header">
                <h4>{email}</h4>
                <span className={`avg-badge ${data.averageScore >= 70 ? 'pass' : 'fail'}`}>
                  {data.averageScore}% avg
                </span>
              </div>
              <div className="student-stats">
                <div className="stat-item">
                  <span className="label">Total Score:</span>
                  <span className="value">{data.totalScore}%</span>
                </div>
                <div className="stat-item">
                  <span className="label">Quizzes Taken:</span>
                  <span className="value">{data.attempts}</span>
                </div>
                <div className="stat-item">
                  <span className="label">Quarters:</span>
                  <span className="value">{data.quarters.join(', ')}</span>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="quarter-stats">
        <h3>Performance by Quarter</h3>
        <div className="quarter-grid">
          {[1, 2, 3, 4].map(quarter => {
            const qStats = getQuarterStats(quarter);
            return (
              <div key={quarter} className={`quarter-stat q${quarter}`}>
                <h4>Quarter {quarter}</h4>
                <p>{qStats.attempts} attempts</p>
                <p className="avg-score">{qStats.avg}% avg</p>
              </div>
            );
          })}
        </div>
      </div>

      <div className="topic-performance">
        <h3>Topic Performance</h3>
        <div className="topic-list">
          {Object.entries(stats.topicPerformance).map(([topic, perf]) => (
            <div key={topic} className="topic-item">
              <div className="topic-info">
                <span className="topic-name">{topic}</span>
                <span className="topic-count">{perf.count} attempts</span>
              </div>
              <div className="progress-bar">
                <div 
                  className="progress-fill" 
                  style={{ width: `${perf.average}%` }}
                >
                  {perf.average}%
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      <div className="filter-section">
        <div className="filter-group">
          <label>Filter by Quarter:</label>
          <select 
            value={selectedQuarter} 
            onChange={(e) => setSelectedQuarter(e.target.value)}
          >
            <option value="all">All Quarters</option>
            <option value="1">Quarter 1</option>
            <option value="2">Quarter 2</option>
            <option value="3">Quarter 3</option>
            <option value="4">Quarter 4</option>
          </select>
        </div>
        
        <div className="filter-group">
          <label>Filter by Topic:</label>
          <select 
            value={selectedTopic} 
            onChange={(e) => setSelectedTopic(e.target.value)}
          >
            <option value="all">All Topics</option>
            {uniqueTopics.map(topic => (
              <option key={topic} value={topic}>{topic}</option>
            ))}
          </select>
        </div>
        
        <div className="filter-group">
          <label>Filter by Student:</label>
          <select 
            value={selectedStudent} 
            onChange={(e) => setSelectedStudent(e.target.value)}
          >
            <option value="all">All Students</option>
            {uniqueStudents.map(email => (
              <option key={email} value={email}>{email}</option>
            ))}
          </select>
        </div>
      </div>

      {loading ? (
        <p>Loading progress data...</p>
      ) : (
        <div className="progress-table">
          <table>
            <thead>
              <tr>
                <th>Student</th>
                <th>Quarter</th>
                <th>Topic</th>
                <th>Score</th>
                <th>Correct/Total</th>
                <th>Date</th>
              </tr>
            </thead>
            <tbody>
              {filteredProgress.map(p => (
                <tr key={p.id}>
                  <td>{p.studentEmail || p.userId || 'Anonymous'}</td>
                  <td>
                    <span className={`quarter-badge q${p.quarter}`}>Q{p.quarter}</span>
                  </td>
                  <td>{p.topic}</td>
                  <td>
                    <span className={`score ${p.score >= 70 ? 'pass' : 'fail'}`}>
                      {p.score}%
                    </span>
                  </td>
                  <td>{p.correctAnswers || 0}/{p.totalQuestions || 0}</td>
                  <td>{p.completedAt?.toLocaleDateString() || 'N/A'}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default ProgressMonitor;
