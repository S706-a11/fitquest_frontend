# Backend API Field Mapping

## Important: Field Name Differences

Your backend API uses different field names than what might be expected. Here's the mapping:

### User Fields

| Frontend (Display) | Backend API Field | Required | Type   |
| ------------------ | ----------------- | -------- | ------ |
| Name               | `displayName`     | ✅ Yes   | string |
| Email              | `email`           | ✅ Yes   | string |
| Password           | `password`        | ❌ No    | string |
| Level              | `level`           | ❌ No    | int    |
| XP                 | `xp`              | ❌ No    | int    |
| Avatar URL         | `avatarUrl`       | ❌ No    | string |

### ⚠️ Common Mistakes

**WRONG:**

```json
{
  "name": "John Doe",
  "email": "john@example.com"
}
```

**CORRECT:**

```json
{
  "displayName": "John Doe",
  "email": "john@example.com"
}
```

## Database Constraints

Based on the error, the backend database has the following constraints:

- `display_name` column in `users` table is **NOT NULL** (required)
- This means you CANNOT create a user without providing a displayName

## Updated Code

The following files have been updated to use the correct field names:

### ✅ `lib/services/api_service.dart`

- `createUser()` now sends `displayName` instead of `name`
- `updateUser()` now sends `displayName` instead of `name`

### ✅ `lib/models/user.dart`

- `fromJson()` now reads `displayName` from API responses
- Falls back to `name` for backwards compatibility

## Testing

To test if the fix works:

1. **Create a new user via the app:**

   - Name: Test User
   - Email: test@example.com
   - Password: password123

2. **Or use Swagger UI:**

   ```json
   POST /api/users
   {
     "displayName": "Test User",
     "email": "test@example.com",
     "password": "password123"
   }
   ```

3. **Verify the user was created:**
   - Check in your database
   - Or use GET /api/users in Swagger

## If You Still Get Errors

### Error: "null value in column 'display_name'"

**Solution:** The backend is not receiving the displayName field.

- Check that you saved the changes to `api_service.dart`
- Restart your Flutter app (hot reload might not be enough)
- Use browser DevTools Network tab to verify the request body

### Error: "Field 'displayName' not found"

**Solution:** Your backend might use a different field name.

- Check your backend's User model/entity
- Look at the actual API response in Swagger
- Update the field name in `api_service.dart` accordingly

## Backend Field Names (Reference)

If you need to check what fields your backend actually uses:

1. Go to Swagger: `http://localhost:5105/swagger/index.html`
2. Find the `CreateUserDto` schema
3. Look at the exact field names required
4. Update the frontend accordingly

## Example API Calls

### Create User

```dart
final response = await ApiService.createUser(
  name: 'John Doe',        // Internally mapped to displayName
  email: 'john@example.com',
  password: 'password123',
);
```

### Update User

```dart
await ApiService.updateUser(
  userId: 1,
  name: 'Jane Doe',        // Internally mapped to displayName
  email: 'jane@example.com',
);
```

### Get User

```dart
final userData = await ApiService.getUserById(1);
// userData['displayName'] -> User model's 'name' field
```

## Notes

- The frontend User model still uses `name` internally for simplicity
- The mapping happens in the API service layer
- This keeps the frontend code clean and intuitive
- If backend changes, only update `api_service.dart`
