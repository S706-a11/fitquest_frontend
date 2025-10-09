# Troubleshooting Guide - Common Issues

## ✅ Issue Fixed: Field Name Mismatch

### Problem

```
500 Internal Server Error
null value in column "display_name" of relation "users" violates not-null constraint
```

### Cause

The backend database expects `displayName` but the frontend was sending `name`.

### Solution Applied

Updated `lib/services/api_service.dart` to send `displayName` instead of `name` when creating or updating users.

---

## 🔧 How to Test the Fix

### Option 1: Restart the App

```bash
# Stop the current app
# Then restart with hot reload disabled
flutter run
```

### Option 2: Test User Creation

1. Open the app
2. Click "Sign Up"
3. Enter:
   - Name: John Doe
   - Email: john@example.com
   - Password: password123
4. Click "Sign Up"

If successful, you should be redirected to the home page.

---

## 🐛 Other Common Issues

### Issue: CORS Error

```
Access to fetch at 'http://localhost:5105/api/users' has been blocked by CORS policy
```

**Solution:** Add CORS configuration to your backend `Program.cs`:

```csharp
// Before builder.Build()
builder.Services.AddCors(options =>
{
    options.AddDefaultPolicy(policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// After app.Build() and before app.Run()
app.UseCors();
```

**OR** run Flutter on desktop/mobile instead of web:

```bash
flutter run -d windows    # Windows
flutter run -d chrome     # Chrome (still has CORS)
flutter run               # Android/iOS emulator
```

---

### Issue: Connection Refused

```
Failed host lookup: 'localhost'
```

**For Android Emulator:**
Change API URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:5105/api';
```

**For Physical Device:**
Use your computer's IP address:

```dart
static const String baseUrl = 'http://192.168.1.XXX:5105/api';
```

Find your IP:

```bash
# Windows
ipconfig

# Look for IPv4 Address under your network adapter
```

---

### Issue: User Not Found During Login

```
Login failed. Invalid email or password
```

**Causes:**

1. User doesn't exist in database
2. Email spelling is wrong
3. Backend API is not returning users

**Solutions:**

**1. Create a test user via Swagger:**

```
http://localhost:5105/swagger/index.html
POST /api/users
{
  "displayName": "Test User",
  "email": "test@example.com",
  "password": "password123"
}
```

**2. Check if users exist:**

```
GET /api/users
```

**3. Test with API Test Page:**

- Open app → Settings → API Connection Test
- Click "Get All Users"
- Verify users are returned

---

### Issue: App Crashes on Startup

```
Provider not found
```

**Solution:** Make sure `main.dart` has the Provider wrapper:

```dart
return ChangeNotifierProvider(
  create: (_) => UserProvider(),
  child: MaterialApp(...),
);
```

---

### Issue: Hot Reload Not Working

```
Changes not reflecting in app
```

**Solution:**

1. Stop the app completely
2. Run `flutter clean`
3. Run `flutter pub get`
4. Run `flutter run` again

---

### Issue: Cannot See User Data on Home Page

```
Shows loading spinner forever
```

**Possible Causes:**

1. **Not logged in:**

   - Make sure you logged in successfully
   - Check Settings page - should show user profile

2. **API error:**

   - Open browser DevTools → Console
   - Look for error messages
   - Test API connection in Settings

3. **User ID not saved:**
   ```dart
   // Add debug logging
   final prefs = await SharedPreferences.getInstance();
   print('User ID: ${prefs.getInt('user_id')}');
   ```

---

## 🔍 Debugging Tools

### 1. Browser DevTools (For Web)

- Right-click → Inspect
- Go to Console tab
- Look for error messages
- Go to Network tab to see API calls

### 2. API Test Page

- Open app → Settings → API Connection Test
- Test each endpoint individually
- Verify API is responding

### 3. Swagger UI

- `http://localhost:5105/swagger/index.html`
- Test endpoints directly
- Check request/response formats

### 4. Flutter DevTools

```bash
# In terminal while app is running
flutter pub global activate devtools
flutter pub global run devtools
```

### 5. Print Debugging

Add print statements:

```dart
print('User data: ${user?.toJson()}');
print('API response: $response');
print('Error: $e');
```

---

## 📝 Checklist Before Reporting Issues

- [ ] Backend API is running (`http://localhost:5105/swagger`)
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] CORS configured in backend (for web)
- [ ] Correct API URL for your platform
- [ ] Test user exists in database
- [ ] Browser console shows no errors
- [ ] Network tab shows successful API calls

---

## 🆘 Getting Help

If you're still stuck:

1. **Check the error message carefully**

   - Look for specific field names
   - Note the HTTP status code
   - Read the full stack trace

2. **Test the backend API directly**

   - Use Swagger UI
   - Try the failing endpoint
   - Check if backend returns correct data

3. **Verify field names match**

   - See `FIELD_MAPPING.md`
   - Check backend's DTO/model classes
   - Update frontend to match

4. **Check Flutter logs**

   ```bash
   flutter logs
   ```

5. **Try a clean build**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## ✅ Verification Steps After Fix

After applying any fix:

1. **Stop the app completely**
2. **Restart the app** (not hot reload)
3. **Test user registration:**
   - Create a new user
   - Verify no 500 error
   - Check user appears in database
4. **Test login:**
   - Login with the new user
   - Verify redirect to home page
   - Check user data displays correctly
5. **Test API calls:**
   - Go to Settings → API Connection Test
   - Test all endpoints
   - Verify all return data successfully

---

## 📚 Related Documentation

- `FIELD_MAPPING.md` - Backend field name reference
- `API_INTEGRATION.md` - Complete API documentation
- `QUICK_REFERENCE.md` - Code examples and common tasks
- `ARCHITECTURE.md` - System architecture overview
