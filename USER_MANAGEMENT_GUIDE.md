# User Management Guide

## Overview
The admin panel includes a User Management feature that allows you to manage student accounts, including password resets (via email or manual) and account deletion.

## ⚠️ Backend Setup Required for Manual Password Reset

To use the "Set Password" feature, you need to set up the backend server first. This is a one-time setup.

**Quick Setup:**
1. See **BACKEND_SETUP_GUIDE.md** for detailed instructions
2. Install dependencies: `cd web-admin-backend && npm install`
3. Add `serviceAccountKey.json` from Firebase Console
4. Start server: `npm start`

The "Email Reset" method works without any backend setup.

## Features

### 1. View All Users
- See all registered students in a table format
- View user details: email, username, name, grade, gender
- See registration date and last login time
- Total user count displayed

### 2. Search Users
- Search by email, username, or name
- Real-time filtering as you type
- Shows filtered results count

### 3. Reset Password - Two Methods

#### Method A: Email Reset (Recommended)
- Click "📧 Email Reset" button
- Sends automatic password reset email to user
- User clicks link and creates new password
- No manual intervention needed

#### Method B: Set Password (Manual with Backend)
- Click "🔑 Set Password" button
- Enter or generate a new password
- Password is set directly using Firebase Admin SDK
- Credentials copied to clipboard
- Provide password to user directly
- **Requires backend server to be running**

### 4. Delete User
- Click "🗑️ Delete" button to remove a user
- Requires confirmation before deletion
- Permanently removes user from database
- Cannot be undone

## How to Access

1. **Start the web admin panel:**
   ```bash
   cd web-admin
   npm start
   ```

2. **Login** to the admin panel

3. **Click "User Management"** tab in the navigation

## Method A: Email Reset (Easy & Automatic)

### Step 1: Find the User
- Use the search bar or scroll through the list

### Step 2: Click Email Reset
- Click the "📧 Email Reset" button
- Confirm the action

### Step 3: User Receives Email
- User gets password reset email from Firebase
- User clicks link and creates new password
- Done! ✅

## Method B: Set Password (Manual with Backend)

### Prerequisites
**IMPORTANT:** The backend server must be running for this to work!

1. Open terminal in `web-admin-backend` folder
2. Run `npm install` (first time only)
3. Add `serviceAccountKey.json` (see BACKEND_SETUP_GUIDE.md)
4. Run `npm start`
5. Verify server is running at http://localhost:3001

See **BACKEND_SETUP_GUIDE.md** for detailed setup instructions.

### Step 1: Find the User
- Use the search bar or scroll through the list

### Step 2: Click Set Password
- Click the "🔑 Set Password" button
- A modal will appear

### Step 3: Enter Password
- Type a password (min 8 characters)
- Or click "🎲 Generate" for random password
- Click "Set Password"

### Step 4: Password is Set Automatically
The system will:
1. Contact the backend server
2. Use Firebase Admin SDK to set the password
3. Copy credentials to your clipboard
4. Show success message

### Step 5: Provide Password to User
- Give the user their new password directly
- User can login immediately with email and new password

## Important Notes

### Email Reset Method
- ✅ **Recommended** - easiest and most secure
- ✅ Fully automatic
- ✅ User creates their own password
- ✅ No manual steps required
- ⚠️ User must have valid email
- ⚠️ User must check email (including spam)

### Set Password Method
- ⚠️ Requires backend server running
- ⚠️ You must provide password to user
- ⚠️ Requires initial setup (serviceAccountKey.json)
- ✅ Works when email is not accessible
- ✅ You control the password
- ✅ Instant password change

### Delete User
- ⚠️ **Permanent action** - cannot be undone
- ⚠️ Deletes user from Firestore database
- ⚠️ User's quiz history may be affected
- ✅ Requires confirmation

## When to Use Each Method

### Use Email Reset When:
- User has access to their email
- You want the easiest solution
- User should create their own password
- **This is the default choice**

### Set Password When:
- User cannot access their email
- You need immediate access for the user
- You want to provide a temporary password
- Email delivery is not working
- **Backend server is set up and running**

## Troubleshooting

### Email Reset Not Working
1. Check user's spam/junk folder
2. Verify email address is correct
3. Check Firebase Authentication settings
4. Try "Set Password" method instead

### Set Password Not Working
1. **Check if backend server is running**
   - Open terminal in `web-admin-backend`
   - Run `npm start`
   - Should see "Admin Backend Server running"
2. **Verify serviceAccountKey.json exists**
   - See BACKEND_SETUP_GUIDE.md for setup
3. **Check browser console for errors**
4. **Try Email Reset method instead**

## Security Best Practices

1. **Prefer Email Reset** - more secure and automatic
2. **Verify User Identity** before resetting passwords
3. **Use Strong Passwords** when setting manually
4. **Inform Users** when you reset their password
5. **Don't Share Passwords** via insecure channels

## Quick Comparison

| Feature | Email Reset | Set Password |
|---------|-------------|--------------|
| Ease of Use | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Security | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Speed | Fast | Instant |
| User Control | User sets password | Admin sets password |
| Email Required | Yes | No |
| Manual Steps | None | Backend setup |
| Setup Required | None | One-time backend setup |
| **Recommended** | ✅ Yes | When email unavailable |
