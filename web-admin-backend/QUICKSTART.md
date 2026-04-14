# Quick Start Guide

## First Time Setup (5 minutes)

### 1. Install Dependencies
```bash
npm install
```

### 2. Get Service Account Key

1. Go to https://console.firebase.google.com/
2. Select your MathNav project
3. Click ⚙️ > Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Save as `serviceAccountKey.json` in this folder

### 3. Start Server
```bash
npm start
```

That's it! The server will run on http://localhost:3001

## Every Time After

Just run:
```bash
npm start
```

## Verify It's Working

Open in browser: http://localhost:3001/api/health

Should see: `{"status":"ok","message":"Admin backend is running"}`

## Troubleshooting

### "Cannot find module './serviceAccountKey.json'"
- You need to download the service account key (see step 2 above)

### "Port 3001 already in use"
- Change PORT in `.env` file to 3002 or another port

### Need more help?
- See README.md for detailed documentation
- See BACKEND_SETUP_GUIDE.md in parent folder
