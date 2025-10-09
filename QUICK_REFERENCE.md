# Quick Reference Guide - Common Tasks

## 🚀 Getting Started

### First Time Setup

```bash
# 1. Navigate to project
cd c:\GitHub\fitquest_frontend

# 2. Install dependencies
flutter pub get

# 3. Ensure backend is running
# Visit http://localhost:5105/swagger/index.html

# 4. Run the app
flutter run
```

### Test API Connection

1. Open app
2. Navigate to Settings (5th tab)
3. Tap "API Connection Test"
4. Test each endpoint

---

## 👤 User Management

### Get Current User

```dart
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

// In your widget:
final userProvider = Provider.of<UserProvider>(context, listen: false);
final user = userProvider.user;

if (user != null) {
  print('User: ${user.name}, Level: ${user.level}');
}
```

### Check if User is Logged In

```dart
final userProvider = Provider.of<UserProvider>(context, listen: false);

if (userProvider.isLoggedIn) {
  // User is logged in
} else {
  // User is not logged in
}
```

### Logout User

```dart
final userProvider = Provider.of<UserProvider>(context, listen: false);
await userProvider.logout();

// Navigate to login
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const LoginPage()),
  (route) => false,
);
```

### Refresh User Data

```dart
final userProvider = Provider.of<UserProvider>(context, listen: false);
await userProvider.refreshUser();
```

---

## 🎯 Quest Management

### Get Active Quests

```dart
import '../services/api_service.dart';

final userId = userProvider.user!.id;
final quests = await ApiService.getActiveQuests(userId);

for (var quest in quests) {
  print('Quest: ${quest['title']}');
  print('Progress: ${quest['progress']}%');
}
```

### Get All Quests

```dart
final quests = await ApiService.getUserQuests(userId);
```

### Get Completed Quests

```dart
final completed = await ApiService.getCompletedQuests(userId);
```

### Create New Quest

```dart
await ApiService.createQuest(
  userId: userId,
  title: 'Morning Workout',
  description: 'Complete 30 min cardio',
  xpReward: 100,
  priority: 'High', // 'Low', 'Medium', or 'High'
);
```

### Toggle Quest Completion

```dart
await ApiService.toggleQuestStatus(
  userId: userId,
  questId: questId,
);
```

---

## 💪 Exercise Management

### Get All Exercises

```dart
final exercises = await ApiService.getExercises();

for (var exercise in exercises) {
  print('Exercise: ${exercise['name']}');
}
```

### Get Exercise Types

```dart
final types = await ApiService.getExerciseTypes();

for (var type in types) {
  print('Type: ${type['name']}');
}
```

---

## ⭐ XP and Leveling

### Add XP to User

```dart
final userProvider = Provider.of<UserProvider>(context, listen: false);

// This automatically handles level-up
await userProvider.addXp(50);

// Show success message
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('+50 XP earned!')),
);
```

### Calculate Next Level XP

```dart
final user = userProvider.user;
if (user != null) {
  final xpNeeded = user.nextLevelXp; // level * 100
  final currentXp = user.xp;
  final remaining = xpNeeded - currentXp;

  print('Need $remaining more XP to level up');
}
```

### Check Level Progress

```dart
final user = userProvider.user!;
final progress = user.xp / user.nextLevelXp;

// Use in progress bar
LinearProgressIndicator(value: progress);
```

---

## 🎨 UI Patterns

### Show Loading State

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  bool _isLoading = false;

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Your API call here
      await ApiService.getUsers();
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return YourContent();
  }
}
```

### Show Error Message

```dart
void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
}
```

### Show Success Message

```dart
void _showSuccess(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Color(0xFF00FF99),
      duration: Duration(seconds: 2),
    ),
  );
}
```

### Use Consumer for Auto-Updates

```dart
import 'package:provider/provider.dart';

Consumer<UserProvider>(
  builder: (context, userProvider, child) {
    final user = userProvider.user;

    if (user == null) {
      return Text('Not logged in');
    }

    return Text('Welcome ${user.name}!');
  },
)
```

---

## 🔧 API Configuration

### Change API Base URL

**File:** `lib/services/api_service.dart`

```dart
class ApiService {
  // For development (local backend)
  static const String baseUrl = 'http://localhost:5105/api';

  // For Android Emulator
  // static const String baseUrl = 'http://10.0.2.2:5105/api';

  // For physical device (use your computer's IP)
  // static const String baseUrl = 'http://192.168.1.100:5105/api';

  // For production
  // static const String baseUrl = 'https://api.fitquest.com/api';
}
```

---

## 🧪 Testing & Debugging

### Test API Endpoint

```dart
// Anywhere in your code
try {
  final response = await ApiService.getUsers();
  print('Success: $response');
} catch (e) {
  print('Error: $e');
}
```

### Print User Data

```dart
final user = Provider.of<UserProvider>(context, listen: false).user;
print('User ID: ${user?.id}');
print('Name: ${user?.name}');
print('Email: ${user?.email}');
print('Level: ${user?.level}');
print('XP: ${user?.xp}');
```

### Check Shared Preferences

```dart
import 'package:shared_preferences/shared_preferences.dart';

final prefs = await SharedPreferences.getInstance();
print('User ID: ${prefs.getInt('user_id')}');
print('User Name: ${prefs.getString('user_name')}');
print('User Email: ${prefs.getString('user_email')}');
```

---

## 📱 Navigation

### Navigate to Page

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NewPage()),
);
```

### Navigate and Replace

```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => NewPage()),
);
```

### Navigate and Clear Stack

```dart
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => NewPage()),
  (route) => false, // Removes all previous routes
);
```

### Go Back

```dart
Navigator.pop(context);
```

---

## 🔐 Authentication Helpers

### Protect a Page (Require Login)

```dart
class ProtectedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (!userProvider.isLoggedIn) {
      // Redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      });
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return YourProtectedContent();
  }
}
```

### Get User ID

```dart
final userId = Provider.of<UserProvider>(context, listen: false).user?.id;

if (userId != null) {
  // Use userId for API calls
}
```

---

## 🎯 Common Use Cases

### Display User Avatar

```dart
final user = Provider.of<UserProvider>(context).user;

CircleAvatar(
  radius: 30,
  backgroundImage: user?.avatarUrl != null
      ? NetworkImage(user!.avatarUrl!)
      : NetworkImage('https://i.pravatar.cc/150?img=1'),
)
```

### Show XP Bar

```dart
import '../widgets/xp_bar.dart';

final user = userProvider.user!;

XPBar(
  xp: user.xp,
  level: user.level,
  nextLevelXp: user.nextLevelXp,
)
```

### Create a Quest Card

```dart
Card(
  child: ListTile(
    title: Text(quest['title']),
    subtitle: Text('${quest['xpReward']} XP'),
    trailing: IconButton(
      icon: Icon(Icons.check),
      onPressed: () async {
        await ApiService.toggleQuestStatus(
          userId: userId,
          questId: quest['id'],
        );
      },
    ),
  ),
)
```

---

## 🚨 Error Handling

### Handle API Errors

```dart
try {
  final response = await ApiService.getUsers();
  // Process response
} on Exception catch (e) {
  if (e.toString().contains('404')) {
    _showError('User not found');
  } else if (e.toString().contains('500')) {
    _showError('Server error. Please try again later.');
  } else {
    _showError('Network error. Check your connection.');
  }
}
```

### Graceful Degradation

```dart
Future<List<dynamic>> _loadQuests() async {
  try {
    return await ApiService.getActiveQuests(userId);
  } catch (e) {
    print('Error loading quests: $e');
    return []; // Return empty list instead of crashing
  }
}
```

---

## 📋 Cheat Sheet

| Task               | Method                                     | File               |
| ------------------ | ------------------------------------------ | ------------------ |
| Get current user   | `userProvider.user`                        | Any page           |
| Check if logged in | `userProvider.isLoggedIn`                  | Any page           |
| Login              | `userProvider.login(email, pass)`          | login_page.dart    |
| Register           | `userProvider.register(name, email, pass)` | register_page.dart |
| Logout             | `userProvider.logout()`                    | settings_page.dart |
| Add XP             | `userProvider.addXp(amount)`               | Any page           |
| Get quests         | `ApiService.getActiveQuests(userId)`       | Any page           |
| Create quest       | `ApiService.createQuest(...)`              | quests_page.dart   |
| Toggle quest       | `ApiService.toggleQuestStatus(...)`        | Any page           |

---

## 🔍 Finding Things

| What          | Where                              |
| ------------- | ---------------------------------- |
| API endpoints | `lib/services/api_service.dart`    |
| User state    | `lib/providers/user_provider.dart` |
| Auth logic    | `lib/services/auth_service.dart`   |
| User model    | `lib/models/user.dart`             |
| Login UI      | `lib/pages/login_page.dart`        |
| Home UI       | `lib/pages/home_page.dart`         |
| Theme colors  | `lib/theme.dart`                   |

---

**Need more help?** Check:

- `API_INTEGRATION.md` - Detailed API documentation
- `ARCHITECTURE.md` - System architecture diagrams
- `IMPLEMENTATION_SUMMARY.md` - Feature checklist
