# FitQuest API Integration Guide

## Overview

This Flutter app is now integrated with the FitQuest API running at `http://localhost:5105`. The integration includes user authentication, user management, and quest tracking features.

## Architecture

### Services Layer

- **`lib/services/api_service.dart`** - Handles all HTTP communication with the backend API
- **`lib/services/auth_service.dart`** - Manages user authentication and local session storage

### State Management

- **`lib/providers/user_provider.dart`** - Uses Provider package for global user state management
- Handles login, registration, logout, and user data updates
- Automatically syncs XP and level changes with the backend

### Models

- **`lib/models/user.dart`** - User data model with JSON serialization

## API Endpoints Used

### Users

- `GET /api/users` - Get all users (used for login)
- `POST /api/users` - Create new user (registration)
- `GET /api/users/{id}` - Get user by ID
- `PUT /api/users/{id}` - Update user (XP, level, etc.)

### Quests

- `GET /api/users/{userId}/quests` - Get all user quests
- `GET /api/users/{userId}/quests/active` - Get active quests
- `GET /api/users/{userId}/quests/completed` - Get completed quests
- `POST /api/users/{userId}/quests` - Create new quest
- `PATCH /api/users/{userId}/quests/{id}/toggle` - Toggle quest completion

### Exercises

- `GET /api/exercises` - Get all exercises
- `GET /api/exercise-types` - Get exercise types

## Features Implemented

### 1. User Authentication

**Login (`lib/pages/login_page.dart`)**

- Email-based login
- Validates credentials against API
- Shows loading state and error messages
- Stores user session locally using SharedPreferences

**Registration (`lib/pages/register_page.dart`)**

- Creates new user via API
- Validates input fields
- Automatically logs in after successful registration
- Shows loading state and error messages

### 2. Home Page (`lib/pages/home_page.dart`)

- Displays logged-in user information (name, level)
- Shows dynamic XP bar based on user's current XP and level
- Loads and displays active quests from the API
- Shows progress for each quest
- Falls back to placeholder message if no quests exist

### 3. User State Management

The `UserProvider` class manages:

- Current user session
- Login/logout operations
- User data refresh
- XP and level updates with automatic level-up calculation

## How to Use

### Starting the App

1. Ensure the backend API is running at `http://localhost:5105`
2. Run the Flutter app: `flutter run`

### Login Flow

1. User enters email and password
2. App searches for user by email via API
3. If found, user data is loaded and session is saved
4. User is navigated to the home screen

### Registration Flow

1. User enters name, email, and password
2. App creates new user via API POST request
3. User data is saved locally
4. User is automatically logged in and navigated to home

### Fetching User Data

```dart
// Get current user
final userProvider = Provider.of<UserProvider>(context, listen: false);
final user = userProvider.user;

// Refresh user data from API
await userProvider.refreshUser();
```

### Managing Quests

```dart
// Load active quests
final quests = await ApiService.getActiveQuests(userId);

// Create a quest
await ApiService.createQuest(
  userId: userId,
  title: 'Morning Run',
  description: 'Run 5km',
  xpReward: 100,
  priority: 'High',
);

// Toggle quest completion
await ApiService.toggleQuestStatus(userId: userId, questId: questId);
```

### Updating XP

```dart
final userProvider = Provider.of<UserProvider>(context, listen: false);
await userProvider.addXp(50); // Adds 50 XP and handles level-up
```

## Data Models

### User Model

```dart
class User {
  final int id;
  final String name;
  final String email;
  final int level;
  final int xp;
  final String? avatarUrl;

  int get nextLevelXp => level * 100; // XP needed for next level
}
```

## Error Handling

- All API calls include try-catch blocks
- Errors are displayed via SnackBar notifications
- Loading states prevent multiple simultaneous requests
- Fallback to cached data when API is unavailable

## Local Storage

Uses `shared_preferences` to store:

- User ID
- User name
- User email

This allows the app to maintain session state across restarts.

## Next Steps

### Recommended Enhancements

1. **Add JWT token authentication** - Currently using simple email lookup
2. **Implement password hashing** - Store and verify passwords securely
3. **Add quest creation UI** - Allow users to create custom quests
4. **Implement quest exercises** - Link exercises to quests
5. **Add leaderboard API integration** - Show user rankings
6. **Implement daily/monthly goals** - Use goal endpoints from API
7. **Add offline support** - Cache data for offline viewing
8. **Implement real-time sync** - Use WebSockets for live updates

### API Endpoints Not Yet Implemented

- Daily Goals (`/api/daily-goals`)
- Monthly Goals (`/api/monthly-goals`)
- Exercise management
- Quest exercises
- User avatar upload

## Testing

### Test the API Connection

```dart
// In your terminal or debug console
final users = await ApiService.getUsers();
print(users);
```

### Create a Test User via Swagger

1. Go to `http://localhost:5105/swagger/index.html`
2. Use POST `/api/users` endpoint
3. Create a test user:

```json
{
  "name": "Test User",
  "email": "test@example.com",
  "password": "password123"
}
```

4. Use these credentials to log into the app

## Troubleshooting

### Cannot connect to API

- Ensure backend is running on `http://localhost:5105`
- Check if swagger UI loads at `http://localhost:5105/swagger/index.html`
- For Android emulator, use `http://10.0.2.2:5105` instead
- For iOS simulator, `http://localhost:5105` should work

### Update API Base URL

Edit `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP_ADDRESS:5105/api';
```

### Login fails

- Check if user exists in database
- Verify email is correct (case-insensitive search)
- Check backend logs for errors
- Use Swagger UI to verify user exists

## Dependencies Added

```yaml
dependencies:
  http: ^1.1.0 # HTTP client for API calls
  shared_preferences: ^2.2.2 # Local storage for session
  provider: ^6.1.1 # State management
```
