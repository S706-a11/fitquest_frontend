# Common Registration & Login Errors

## ✅ Error Fixed: Better Error Messages

The app now shows user-friendly error messages when registration or login fails.

---

## 🔍 Common Registration Errors

### 1. Email Already Exists

**Error Message:**

```
This email is already registered. Please login or use a different email.
```

**What it means:**

- The email you're trying to register is already in the database
- Someone (probably you!) already created an account with this email

**Solutions:**

1. **Use the Login page** with your existing email
2. **Use a different email** for registration
3. **Check if you already have an account**

**Quick Test:**

```
Try logging in with: your_email@example.com
If login works, the account already exists!
```

---

### 2. Name is Required

**Error Message:**

```
Name is required. Please enter your name.
```

**What it means:**

- The backend database requires a display name
- You left the name field empty

**Solution:**

- Enter your name in the registration form

---

### 3. Server Error

**Error Message:**

```
Server error. Please try again later.
```

**What it means:**

- Backend API encountered an unexpected error
- Database might be down
- Backend code has a bug

**Solutions:**

1. Check if backend is running: http://localhost:5105/swagger
2. Check backend console for error details
3. Restart the backend API
4. Check database connection

---

### 4. Invalid Input

**Error Message:**

```
Invalid input. Please check your information.
```

**What it means:**

- The data you entered doesn't meet validation requirements

**Solutions:**

- Check password length (usually min 6 characters)
- Verify email format (must be valid email)
- Ensure all required fields are filled

---

## 🔍 Common Login Errors

### 1. Invalid Email or Password

**Error Message:**

```
Invalid email or password
```

**What it means:**

- User not found in database
- Email doesn't match any existing account

**Solutions:**

1. **Check your email spelling**
2. **Register first** if you don't have an account
3. **Use the API Test** to see all users:
   - Settings → API Connection Test → Get All Users

---

### 2. Network Error

**Error Message:**

```
Failed host lookup: 'localhost'
```

**What it means:**

- Cannot connect to backend API

**Solutions:**

1. **Start your backend API** (port 5105)
2. **For Android emulator:** Change API URL to `http://10.0.2.2:5105/api`
3. **Check firewall settings**

---

## 🛠️ Debugging Tips

### Check if Email Already Exists

#### Option 1: Via Swagger UI

1. Go to http://localhost:5105/swagger/index.html
2. Open `GET /api/users`
3. Click "Try it out" → "Execute"
4. Search for your email in the response

#### Option 2: Via API Test Page

1. Open your Flutter app
2. Navigate to Settings
3. Click "API Connection Test"
4. Click "Get All Users"
5. Look for your email in the results

---

### Test User Registration Manually

#### Via Swagger UI:

```
POST /api/users
{
  "displayName": "Test User",
  "email": "test123@example.com",
  "password": "password123"
}
```

If you get a 200 response, registration works!
If you get a 500 error, check the backend logs.

---

### Clear Existing User (If Needed)

If you want to re-register with the same email:

#### Option 1: Delete via Swagger (if DELETE endpoint exists)

```
DELETE /api/users/{id}
```

#### Option 2: Clear Database

- Stop backend
- Clear users table in database
- Restart backend

#### Option 3: Use a Different Email

- Just add a number: john.doe2@example.com

---

## 📋 Quick Checklist for Registration

Before clicking "Sign Up":

- [ ] Backend is running (http://localhost:5105/swagger)
- [ ] CORS is configured for port 3000
- [ ] Name field is filled
- [ ] Email is valid format
- [ ] Email is NOT already registered
- [ ] Password is at least 6 characters

---

## 💡 Pro Tips

### Tip 1: Test with Unique Emails

Use timestamps to create unique test emails:

```
test1@example.com
test2@example.com
test3@example.com
```

### Tip 2: Check Backend Logs

The backend console shows detailed error messages that can help debug issues.

### Tip 3: Use API Test Page

The built-in API Test page (Settings → API Connection Test) helps you:

- Verify backend is reachable
- See all registered users
- Test individual endpoints

### Tip 4: Login Instead of Register

If registration fails with "email already exists", just use the Login page!

---

## 🎯 Example Workflow

### First Time User:

1. ✅ Open app → Click "Sign Up"
2. ✅ Enter name, email, password
3. ✅ Click "Sign Up"
4. ✅ Auto-login → Redirected to home

### Returning User:

1. ✅ Open app → Enter email, password
2. ✅ Click "Log In"
3. ✅ Redirected to home

### If Email Exists:

1. ❌ Try to register
2. ⚠️ See error: "This email is already registered"
3. ✅ Click "Already have an account? Log In"
4. ✅ Login with existing credentials

---

## 🐛 Still Having Issues?

### Step 1: Verify Backend is Working

```bash
# Check if swagger loads
http://localhost:5105/swagger/index.html
```

### Step 2: Test API Directly

Use Swagger UI to create a user and verify it works.

### Step 3: Check CORS

Make sure backend allows `http://localhost:3000`

### Step 4: Check Browser Console

Open DevTools (F12) → Console tab → Look for errors

### Step 5: Try Different Email

Sometimes the simplest solution is just using a different email!

---

## ✅ Success Indicators

You'll know registration worked when:

- ✅ No error message appears
- ✅ You're redirected to the home page
- ✅ Your name appears in the home page
- ✅ Settings page shows your profile

---

## 📚 Related Documentation

- **TROUBLESHOOTING.md** - General troubleshooting guide
- **API_INTEGRATION.md** - API endpoint details
- **FIELD_MAPPING.md** - Backend field names
- **HOW_TO_RUN.md** - How to start the app

---

## 🎉 Summary

The app now shows clear, user-friendly error messages:

| Error Type          | What You'll See                                     |
| ------------------- | --------------------------------------------------- |
| Duplicate email     | "This email is already registered. Please login..." |
| Missing name        | "Name is required. Please enter your name."         |
| Server error        | "Server error. Please try again later."             |
| Invalid credentials | "Invalid email or password"                         |

**Just read the error message and follow the suggested solution!** 🚀
