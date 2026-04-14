import React, { useState, useEffect } from 'react';
import { collection, getDocs, addDoc, updateDoc, deleteDoc, doc } from 'firebase/firestore';
import { db } from '../firebase';
import './QuizManagement.css';

function QuizManagement() {
  const [quizzes, setQuizzes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [editingQuiz, setEditingQuiz] = useState(null);
  const [selectedQuarter, setSelectedQuarter] = useState('all');
  const [selectedTopic, setSelectedTopic] = useState('all');

  const quarters = [
    { id: 1, name: 'Quarter 1', topic: 'Numbers and Operations' },
    { id: 2, name: 'Quarter 2', topic: 'Fractions and Decimals' },
    { id: 3, name: 'Quarter 3', topic: 'Geometry and Measurement' },
    { id: 4, name: 'Quarter 4', topic: 'Ratios, Percentages, Data' }
  ];

  const topicsByQuarter = {
    1: ['Adding Simple Fractions Without Regrouping', 'Adding Simple Fractions With Regrouping in the Sum', 'Adding Simple Fractions and Mixed Numbers With Regrouping in the Sum'],
    2: ['Fractions', 'Decimals', 'Fraction Operations', 'Decimal Operations'],
    3: ['Geometry', 'Perimeter and Area', 'Volume', 'Angles and Shapes'],
    4: ['Ratios', 'Percentages', 'Data and Statistics', 'Probability']
  };

  const [formData, setFormData] = useState({
    quarter: 1,
    topic: '',
    difficulty: 1,
    question: '',
    options: ['', '', '', ''],
    correctAnswerIndex: 0,
    explanation: ''
  });

  useEffect(() => {
    fetchQuizzes();
  }, []);

  const fetchQuizzes = async () => {
    try {
      const querySnapshot = await getDocs(collection(db, 'quizzes'));
      const quizList = querySnapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setQuizzes(quizList);
    } catch (error) {
      console.error('Error fetching quizzes:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    try {
      if (editingQuiz) {
        await updateDoc(doc(db, 'quizzes', editingQuiz.id), {
          ...formData,
          updatedAt: new Date()
        });
      } else {
        await addDoc(collection(db, 'quizzes'), {
          ...formData,
          createdAt: new Date()
        });
      }
      
      resetForm();
      fetchQuizzes();
      setShowModal(false);
    } catch (error) {
      console.error('Error saving quiz:', error);
      alert('Error saving quiz: ' + error.message);
    }
  };

  const handleEdit = (quiz) => {
    setEditingQuiz(quiz);
    setFormData({
      quarter: quiz.quarter,
      topic: quiz.topic,
      difficulty: quiz.difficulty,
      question: quiz.question,
      options: quiz.options,
      correctAnswerIndex: quiz.correctAnswerIndex,
      explanation: quiz.explanation
    });
    setShowModal(true);
  };

  const handleDelete = async (id) => {
    if (window.confirm('Are you sure you want to delete this quiz?')) {
      try {
        await deleteDoc(doc(db, 'quizzes', id));
        fetchQuizzes();
      } catch (error) {
        console.error('Error deleting quiz:', error);
      }
    }
  };

  const resetForm = () => {
    setFormData({
      quarter: 1,
      topic: '',
      difficulty: 1,
      question: '',
      options: ['', '', '', ''],
      correctAnswerIndex: 0,
      explanation: ''
    });
    setEditingQuiz(null);
  };

  const handleOptionChange = (index, value) => {
    const newOptions = [...formData.options];
    newOptions[index] = value;
    setFormData({ ...formData, options: newOptions });
  };

  const filteredQuizzes = quizzes.filter(q => {
    const quarterMatch = selectedQuarter === 'all' || q.quarter === parseInt(selectedQuarter);
    const topicMatch = selectedTopic === 'all' || q.topic === selectedTopic;
    return quarterMatch && topicMatch;
  });

  const uniqueTopics = [...new Set(quizzes.map(q => q.topic))].filter(Boolean).sort();

  const getQuizzesByQuarter = (quarterId) => {
    return quizzes.filter(q => q.quarter === quarterId).length;
  };

  return (
    <div className="quiz-management">
      <div className="quiz-header">
        <h2>Quiz Management</h2>
        <button className="btn-primary" onClick={() => setShowModal(true)}>
          + Create New Quiz
        </button>
      </div>

      <div className="quarters-overview">
        {quarters.map(quarter => (
          <div key={quarter.id} className="quarter-card">
            <h3>{quarter.name}</h3>
            <p className="quarter-topic">{quarter.topic}</p>
            <p className="quiz-count">{getQuizzesByQuarter(quarter.id)} Quizzes</p>
          </div>
        ))}
      </div>

      <div className="filter-section">
        <div className="filter-group">
          <label>Filter by Quarter:</label>
          <select 
            value={selectedQuarter} 
            onChange={(e) => setSelectedQuarter(e.target.value)}
          >
            <option value="all">All Quarters</option>
            {quarters.map(q => (
              <option key={q.id} value={q.id}>Quarter {q.id}</option>
            ))}
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
      </div>

      {loading ? (
        <p>Loading quizzes...</p>
      ) : (
        <div className="quiz-list">
          {filteredQuizzes.map(quiz => (
            <div key={quiz.id} className="quiz-item">
              <div className="quiz-info">
                <span className={`quarter-badge q${quiz.quarter}`}>
                  Q{quiz.quarter}
                </span>
                <div className="quiz-details">
                  <h4>{quiz.question}</h4>
                  <p className="quiz-topic">{quiz.topic}</p>
                  <div className="difficulty">
                    {[...Array(3)].map((_, i) => (
                      <span key={i} className={i < quiz.difficulty ? 'star-filled' : 'star-empty'}>
                        ★
                      </span>
                    ))}
                  </div>
                </div>
              </div>
              <div className="quiz-actions">
                <button className="btn-edit" onClick={() => handleEdit(quiz)}>
                  Edit
                </button>
                <button className="btn-delete" onClick={() => handleDelete(quiz.id)}>
                  Delete
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {showModal && (
        <div className="modal-overlay" onClick={() => { setShowModal(false); resetForm(); }}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h3>{editingQuiz ? 'Edit Quiz' : 'Create New Quiz'}</h3>
            <form onSubmit={handleSubmit}>
              <div className="form-row">
                <div className="form-group">
                  <label>Quarter</label>
                  <select
                    value={formData.quarter}
                    onChange={(e) => {
                      const newQuarter = parseInt(e.target.value);
                      setFormData({ 
                        ...formData, 
                        quarter: newQuarter,
                        topic: '' // Reset topic when quarter changes
                      });
                    }}
                    required
                  >
                    {quarters.map(q => (
                      <option key={q.id} value={q.id}>Quarter {q.id}</option>
                    ))}
                  </select>
                </div>

                <div className="form-group">
                  <label>Difficulty</label>
                  <select
                    value={formData.difficulty}
                    onChange={(e) => setFormData({ ...formData, difficulty: parseInt(e.target.value) })}
                    required
                  >
                    <option value={1}>Easy (★)</option>
                    <option value={2}>Medium (★★)</option>
                    <option value={3}>Hard (★★★)</option>
                  </select>
                </div>
              </div>

              <div className="form-group">
                <label>Topic</label>
                <select
                  value={formData.topic}
                  onChange={(e) => setFormData({ ...formData, topic: e.target.value })}
                  required
                >
                  <option value="">Select a topic...</option>
                  {topicsByQuarter[formData.quarter].map((topic, index) => (
                    <option key={index} value={topic}>{topic}</option>
                  ))}
                </select>
              </div>

              <div className="form-group">
                <label>Question</label>
                <textarea
                  value={formData.question}
                  onChange={(e) => setFormData({ ...formData, question: e.target.value })}
                  placeholder="Enter the quiz question"
                  rows="3"
                  required
                />
              </div>

              <div className="form-group">
                <label>Options</label>
                {formData.options.map((option, index) => (
                  <div key={index} className="option-input">
                    <input
                      type="text"
                      value={option}
                      onChange={(e) => handleOptionChange(index, e.target.value)}
                      placeholder={`Option ${String.fromCharCode(65 + index)}`}
                      required
                    />
                    <input
                      type="radio"
                      name="correctAnswer"
                      checked={formData.correctAnswerIndex === index}
                      onChange={() => setFormData({ ...formData, correctAnswerIndex: index })}
                    />
                    <label>Correct</label>
                  </div>
                ))}
              </div>

              <div className="form-group">
                <label>Explanation</label>
                <textarea
                  value={formData.explanation}
                  onChange={(e) => setFormData({ ...formData, explanation: e.target.value })}
                  placeholder="Explain the correct answer"
                  rows="2"
                  required
                />
              </div>

              <div className="modal-actions">
                <button type="button" className="btn-cancel" onClick={() => { setShowModal(false); resetForm(); }}>
                  Cancel
                </button>
                <button type="submit" className="btn-submit">
                  {editingQuiz ? 'Update Quiz' : 'Create Quiz'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}

export default QuizManagement;
