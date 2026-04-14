# Backend Setup Guide for User Management

This guide explains how to set up the backend server that enables direct password reset functionality in the admin panel.

## Why Do We Need a Backend?

Firebase doesn't allow password changes directly from the client-side for security reasons. To enable the "Set Password" feature in User Management, we need a backend server using Firebase Admin SDK.

## Setup Steps

### Step 1: Install Backend Dependencies

Open a terminal and navigate to the backend folder:

```bash
cd web-admin-backend
npm install
```

This will install:
- express (web server)
- cors (cross-origin requests)
- firebase-admin (Firebase Admin SDK)
- dotenv (environment variables)

### Step 2: Get Firebase Service Account Key

This is the most important step!

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **MathNav** project
3. Click the **gear icon ⚙️** next to "Project Overview"
4. Select **"Project Settings"**
5. Go to the **"Service Accounts"** tab
6. Click **"Generate New Private Key"** button
7. Click **"Generate Key"** in the confirmation dialog
8. A JSON file will be downloaded (e.g., `mathnav-xxxxx-firebase-adminsdk-xxxxx.json`)
9. **Rename** this file to `serviceAccountKey.json`
10. **Move** it to the `web-admin-backend` folder

**IMPORTANT SECURITY NOTES:**
- ⚠️ Never commit `serviceAccountKey.json` to git (it's already in `.gitignore`)
- ⚠️ Never share this file with anyone
- ⚠️ This file gives full admin access to your Firebase project
- ⚠️ Keep it secure and private

### Step 3: Start the Backend Server

In the `web-admin-backend` folder, run:

```bash
npm start
```

You should see:
```
✅ Firebase Admin SDK initialized successfully
🚀 Admin Backend Server running on http://localhost:3001
📡 API endpoints available at http://localhost:3001/api
```

**For development with auto-reload:**
```bash
npm run dev
```

### Step 4: Test the Backend

Open your browser and go to:
```
http://localhost:3001/api/health
```

You should see:
```json
{"status":"ok","message":"Admin backend is running"}
```

### Step 5: Use in Admin Panel

1. Make sure the backend server is running (Step 3)
2. Open the web admin panel in your browser
3. Go to **"User Management"** tab
4. Find a user and click **"🔑 Set Password"**
5. Enter or generate a password
6. Click **"Set Password"**
7. The password will be set directly in Firebase!

## Troubleshooting

### Error: Cannot find module './serviceAccountKey.json'

**Solution:** You need to download the service account key from Firebase Console (see Step 2).

### Error: Backend server not running

**Solution:** 
1. Open terminal in `web-admin-backend` folder
2. Run `npm start`
3. Make sure you see the success messages

### Port 3001 already in use

**Solution:** 
1. Open `web-admin-backend/.env` file
2. Change `PORT=3001` to another port (e.g., `PORT=3002`)
3. Update the fetch URL in `UserManagement.js` to match the new port

### CORS errors

**Solution:** Make sure:
1. Backend server is running
2. You're accessing the admin panel from `http://localhost:3000`
3. The backend is running on `http://localhost:3001`

### Firebase Admin SDK initialization failed

**Solution:**
1. Make sure `serviceAccountKey.json` is in the correct location
2. Make sure the file is valid JSON
3. Make sure you downloaded it from the correct Firebase project

## How It Works

1. Admin clicks "Set Password" in the User Management panel
2. Frontend sends user's email to backend: `POST /api/users/get-by-email`
3. Backend uses Firebase Admin SDK to get the user's UID
4. Frontend sends UID and new password to backend: `POST /api/users/reset-password`
5. Backend uses Firebase Admin SDK to update the password
6. User can now log in with the new password!

## API Endpoints

The backend provides these endpoints:

- `GET /api/health` - Health check
- `POST /api/users/get-by-email` - Get user UID by email
- `POST /api/users/reset-password` - Set user password
- `POST /api/users/delete` - Delete user (not used yet)
- `GET /api/users/list` - List all users (not used yet)

## Security Considerations

- The backend should only be run locally or on a secure server
- Never expose `serviceAccountKey.json` publicly
- Consider adding authentication to the backend API in production
- The backend has full admin access to Firebase
- Only trusted administrators should have access to the backend

## Production Deployment (Optional)

For production use, you should:

1. Deploy the backend to a secure server (e.g., Heroku, AWS, Google Cloud)
2. Add authentication to the API endpoints
3. Use environment variables for configuration
4. Enable HTTPS
5. Restrict CORS to your admin panel domain only
6. Add rate limiting to prevent abuse

## Need Help?

If you encounter issues:

1. Check the backend terminal for error messages
2. Check the browser console for errors
3. Make sure all steps were followed correctly
4. Verify `serviceAccountKey.json` is in the right place
5. Make sure Firebase project is correctly configured

## Summary

✅ Backend enables direct password reset without email
✅ Uses Firebase Admin SDK for secure operations
✅ Simple setup with npm install and service account key
✅ Works seamlessly with the admin panel
✅ Secure and private (runs locally)
