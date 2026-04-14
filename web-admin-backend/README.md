# MathNav Admin Backend

Backend API server for MathNav admin operations using Firebase Admin SDK.

## Features

- Direct password reset without email
- User management (delete, list)
- Firebase Admin SDK integration

## Setup Instructions

### 1. Install Dependencies

```bash
cd web-admin-backend
npm install
```

### 2. Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your MathNav project
3. Click the gear icon ⚙️ > Project Settings
4. Go to "Service Accounts" tab
5. Click "Generate New Private Key"
6. Save the downloaded JSON file as `serviceAccountKey.json` in this directory (`web-admin-backend/`)

**IMPORTANT:** Never commit `serviceAccountKey.json` to git! It's already in `.gitignore`.

### 3. Configure Environment

The `.env` file is already created with default settings:
```
PORT=3001
NODE_ENV=development
```

You can modify the port if needed.

### 4. Start the Server

```bash
npm start
```

Or for development with auto-reload:
```bash
npm run dev
```

The server will run on `http://localhost:3001`

## API Endpoints

### Health Check
```
GET /api/health
```

### Reset User Password
```
POST /api/users/reset-password
Body: { "uid": "user-uid", "newPassword": "newpass123" }
```

### Get User by Email
```
POST /api/users/get-by-email
Body: { "email": "user@example.com" }
```

### Delete User
```
POST /api/users/delete
Body: { "uid": "user-uid" }
```

### List All Users
```
GET /api/users/list?limit=1000
```

## Usage with Admin Panel

1. Make sure this backend server is running
2. Open the web admin panel
3. Go to "User Management" tab
4. Use the "🔑 Set Password" button to reset passwords directly

## Troubleshooting

### Error: Cannot find module './serviceAccountKey.json'

You need to download the service account key from Firebase Console (see step 2 above).

### Port already in use

Change the PORT in `.env` file to a different port number.

### CORS errors

Make sure the backend server is running and accessible from your admin panel.
