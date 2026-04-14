import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: "AIzaSyDqh5lPPnd7JozJnVRAmPdYQPB-o30lWSc",
  authDomain: "mathnav-69d41.firebaseapp.com",
  projectId: "mathnav-69d41",
  storageBucket: "mathnav-69d41.firebasestorage.app",
  messagingSenderId: "777089147131",
  appId: "1:777089147131:web:f9402a445178d98c6a505e"
};

const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
