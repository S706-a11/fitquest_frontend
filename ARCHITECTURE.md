# FitQuest Frontend Architecture

## Application Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         USER OPENS APP                      │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
         ┌────────────────────┐
         │   LoginPage        │
         │  (Entry Point)     │
         └────────┬───────────┘
                  │
        ┌─────────┴──────────┐
        │                    │
        ▼                    ▼
  ┌──────────┐         ┌──────────┐
  │  Login   │         │ Register │
  └────┬─────┘         └─────┬────┘
       │                     │
       │   AuthService       │
       │   ┌───────────┐     │
       └──►│ API Call  │◄────┘
           └─────┬─────┘
                 │
                 ▼
         ┌───────────────┐
         │ UserProvider  │
         │ (State Mgmt)  │
         └───────┬───────┘
                 │
                 ▼
         ┌───────────────┐
         │   RootShell   │
         │ (Main Nav)    │
         └───────┬───────┘
                 │
    ┌────────────┼────────────┬────────────┬────────────┐
    │            │            │            │            │
    ▼            ▼            ▼            ▼            ▼
┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐
│ Home   │  │Quests  │  │Tracker │  │Leaders │  │Settings│
│ Page   │  │ Page   │  │ Page   │  │ Page   │  │ Page   │
└────────┘  └────────┘  └────────┘  └────────┘  └───┬────┘
                                                      │
                                                      ▼
                                              ┌──────────────┐
                                              │  API Test    │
                                              │    Page      │
                                              └──────────────┘
```

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         PRESENTATION LAYER                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │LoginPage │  │HomePage  │  │QuestsPage│  │ Settings │   │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘   │
│       │             │              │             │          │
│       └─────────────┴──────────────┴─────────────┘          │
│                          │                                  │
└──────────────────────────┼──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      STATE MANAGEMENT LAYER                  │
│                                                              │
│                   ┌────────────────────┐                     │
│                   │   UserProvider     │                     │
│                   │  (ChangeNotifier)  │                     │
│                   │                    │                     │
│                   │ • user: User?      │                     │
│                   │ • isLoading: bool  │                     │
│                   │ • error: String?   │                     │
│                   │                    │                     │
│                   │ Methods:           │                     │
│                   │ • login()          │                     │
│                   │ • register()       │                     │
│                   │ • logout()         │                     │
│                   │ • refreshUser()    │                     │
│                   │ • addXp()          │                     │
│                   └──────────┬─────────┘                     │
│                              │                               │
└──────────────────────────────┼───────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                        SERVICE LAYER                         │
│                                                              │
│  ┌────────────────────┐         ┌─────────────────────┐     │
│  │   AuthService      │         │    ApiService       │     │
│  │                    │         │                     │     │
│  │ • login()          │────────►│ • getUsers()        │     │
│  │ • register()       │────────►│ • createUser()      │     │
│  │ • logout()         │         │ • getUserById()     │     │
│  │ • getCurrentUser() │────────►│ • updateUser()      │     │
│  │ • isLoggedIn()     │         │ • getUserQuests()   │     │
│  │                    │         │ • getActiveQuests() │     │
│  └──────────┬─────────┘         │ • createQuest()     │     │
│             │                   │ • toggleQuest()     │     │
│             │                   └──────────┬──────────┘     │
│             │                              │                │
│             ▼                              ▼                │
│  ┌──────────────────┐          ┌─────────────────────┐     │
│  │SharedPreferences │          │    HTTP Client      │     │
│  │  (Local Cache)   │          │   (REST Calls)      │     │
│  └──────────────────┘          └──────────┬──────────┘     │
│                                            │                │
└────────────────────────────────────────────┼────────────────┘
                                             │
                                             ▼
                              ┌──────────────────────────┐
                              │    BACKEND API           │
                              │  http://localhost:5105   │
                              │                          │
                              │  Endpoints:              │
                              │  • /api/users            │
                              │  • /api/users/{id}       │
                              │  • /api/users/{id}/quests│
                              │  • /api/exercises        │
                              │  • /api/exercise-types   │
                              │  • /api/daily-goals      │
                              │  • /api/monthly-goals    │
                              └──────────────────────────┘
```

## Authentication Flow

```
┌──────────┐
│  USER    │
└────┬─────┘
     │
     │ 1. Enters email & password
     ▼
┌─────────────────┐
│  LoginPage      │
│  _handleLogin() │
└────┬────────────┘
     │
     │ 2. Calls UserProvider.login()
     ▼
┌─────────────────────┐
│   UserProvider      │
│   login()           │
└────┬────────────────┘
     │
     │ 3. Calls AuthService.login()
     ▼
┌──────────────────────┐
│   AuthService        │
│   login()            │
└────┬─────────────────┘
     │
     │ 4. GET /api/users
     ▼
┌──────────────────────┐
│   ApiService         │
│   getUsers()         │
└────┬─────────────────┘
     │
     │ 5. HTTP GET Request
     ▼
┌──────────────────────┐
│   Backend API        │
│   Returns user list  │
└────┬─────────────────┘
     │
     │ 6. Find user by email
     ▼
┌──────────────────────┐
│   AuthService        │
│   Save to local      │
└────┬─────────────────┘
     │
     │ 7. Update state
     ▼
┌──────────────────────┐
│   UserProvider       │
│   _user = user       │
│   notifyListeners()  │
└────┬─────────────────┘
     │
     │ 8. UI rebuilds
     ▼
┌──────────────────────┐
│   LoginPage          │
│   Navigate to Home   │
└──────────────────────┘
```

## State Management Flow

```
┌─────────────────────────────────────────────────────┐
│               Consumer<UserProvider>                │
│                  (Widget Tree)                      │
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │HomePage  │  │Settings  │  │QuestsPage│         │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘         │
│       │             │              │               │
└───────┼─────────────┼──────────────┼───────────────┘
        │             │              │
        │   Listens   │   Listens    │   Listens
        ▼             ▼              ▼
┌───────────────────────────────────────────────────┐
│             UserProvider (State)                  │
│                                                   │
│  State:                                           │
│    • User? _user                                  │
│    • bool _isLoading                              │
│    • String? _error                               │
│                                                   │
│  When state changes:                              │
│    notifyListeners() ──► All Consumers rebuild    │
│                                                   │
└───────────────────────────────────────────────────┘
```

## API Request Lifecycle

```
1. Widget calls API method
        │
        ▼
2. setState(() => _isLoading = true)
        │
        ▼
3. ApiService makes HTTP request
        │
        ├──────────┬──────────┐
        ▼          ▼          ▼
    Success    Error      Timeout
        │          │          │
        ▼          ▼          ▼
4. Process    Catch      Handle
   Response   Exception  Timeout
        │          │          │
        └──────────┴──────────┘
                   │
                   ▼
5. setState(() => _isLoading = false)
                   │
                   ▼
6. Update UI / Show message
```

## Directory Structure

```
lib/
├── main.dart                 # App entry point, Provider setup
├── theme.dart               # App theming
│
├── models/                  # Data models
│   └── user.dart           # User model with JSON serialization
│
├── services/               # Business logic & API communication
│   ├── api_service.dart   # HTTP REST client
│   └── auth_service.dart  # Authentication logic
│
├── providers/              # State management
│   └── user_provider.dart # Global user state
│
├── pages/                  # UI Screens
│   ├── login_page.dart        ✅ API Integrated
│   ├── register_page.dart     ✅ API Integrated
│   ├── home_page.dart         ✅ API Integrated
│   ├── settings_page.dart     ✅ API Integrated
│   ├── api_test_page.dart     ✅ Debug Tool
│   ├── quests_page.dart       🔄 To be integrated
│   ├── quest_tracker_page.dart 🔄 To be integrated
│   └── leaderboard_page.dart  🔄 To be integrated
│
└── widgets/               # Reusable components
    ├── xp_bar.dart       # XP progress bar
    └── quest_card.dart   # Quest card widget
```

## Technology Stack

```
┌───────────────────────────────────────┐
│         Flutter Framework             │
│           (Dart 3.7.2)                │
└─────────────┬─────────────────────────┘
              │
    ┌─────────┴─────────┬───────────────┐
    │                   │               │
    ▼                   ▼               ▼
┌────────┐        ┌──────────┐    ┌──────────┐
│Provider│        │   HTTP   │    │SharedPref│
│ 6.1.1  │        │  1.1.0   │    │  2.2.2   │
└────────┘        └──────────┘    └──────────┘
State Mgmt      REST Client      Local Storage
```

## Key Patterns Used

1. **Provider Pattern** - State management
2. **Repository Pattern** - API abstraction
3. **Service Layer Pattern** - Business logic separation
4. **Consumer Pattern** - Reactive UI updates
5. **Singleton Pattern** - API service instance

## Error Handling Strategy

```
API Call
   │
   ├─► Success ──► Update State ──► Show Data
   │
   └─► Failure
         │
         ├─► Network Error ──► Show Retry Message
         │
         ├─► API Error ──► Show Error from Backend
         │
         └─► Timeout ──► Show Timeout Message
```

---

This architecture ensures:

- ✅ Separation of concerns
- ✅ Testable code
- ✅ Maintainable structure
- ✅ Scalable design
- ✅ Reactive UI updates
