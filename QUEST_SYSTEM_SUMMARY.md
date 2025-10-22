# FitQuest - Quest Template System Summary

## 🎮 System Architecture

### Template-Based Quest System

FitQuest uses a **template-based quest system** where:

- Admin/backend generates **200+ pre-defined quest templates**
- Users **claim quests** from available templates (not create custom quests)
- Templates are **level-gated** (minLevel/maxLevel)
- **Difficulty tiers** scale XP, duration, and target metrics

## 📊 Quest Categories (8 Types)

| Category    | Focus                       | Pattern Count | Example Quest                    |
| ----------- | --------------------------- | ------------- | -------------------------------- |
| General     | Basic exercise              | 5             | Complete 10 exercises            |
| Strength    | Weight training, reps       | 7             | Lift 5000kg total weight         |
| Cardio      | Running, cycling, endurance | 6             | Run for 120 minutes              |
| Flexibility | Yoga, stretching, mobility  | 4             | Practice yoga for 60 minutes     |
| Endurance   | Stamina, long-duration      | 4             | Exercise continuously for 90 min |
| Consistency | Daily streaks, habits       | 5             | Exercise 7 days in a row         |
| WeightLoss  | Calorie burning             | 4             | Burn 2000 calories total         |
| MuscleGain  | Hypertrophy, volume         | 4             | Perform 500 reps with overload   |

**Total**: 39 unique patterns × 5 difficulties = **195+ quest templates**

## 🏆 Difficulty Tiers (5 Levels)

### Beginner (Level 1-5)

- **XP Multiplier**: 1x (~50 XP)
- **Duration**: 7 days
- **Scaling**: Low values (3 exercises, 50 reps, 30 min)
- **Target Audience**: New users learning the system

### Intermediate (Level 6-15)

- **XP Multiplier**: 2x (~100 XP)
- **Duration**: 14 days
- **Scaling**: Medium values (10 exercises, 500 reps, 120 min)
- **Target Audience**: Regular exercisers

### Advanced (Level 16-30)

- **XP Multiplier**: 4x (~200 XP)
- **Duration**: 21 days
- **Scaling**: High values (20 exercises, 2000 reps, 300 min)
- **Target Audience**: Committed athletes

### Expert (Level 31-50)

- **XP Multiplier**: 8x (~400 XP)
- **Duration**: 30 days
- **Scaling**: Very high values (40 exercises, 5000 reps, 600 min)
- **Target Audience**: Elite fitness enthusiasts

### Master (Level 51-100)

- **XP Multiplier**: 15x (~750 XP)
- **Duration**: 45 days
- **Scaling**: Extreme values (60 exercises, 10000 reps, 1200 min)
- **Target Audience**: Champions and hardcore players

## 🎯 Value Scaling Table

| Placeholder | Beginner | Intermediate | Advanced | Expert    | Master    |
| ----------- | -------- | ------------ | -------- | --------- | --------- |
| {count}     | 3        | 10           | 20       | 40        | 60        |
| {duration}  | 30 min   | 120 min      | 300 min  | 600 min   | 1200 min  |
| {reps}      | 50       | 500          | 2,000    | 5,000     | 10,000    |
| {weight}    | 1,000 kg | 5,000 kg     | 30,000kg | 100,000kg | 250,000kg |
| {distance}  | 5 km     | 25 km        | 50 km    | 100 km    | 200 km    |
| {streak}    | 3 days   | 7 days       | 14 days  | 30 days   | 60 days   |
| {sets}      | 5        | 20           | 50       | 100       | 200       |
| {calories}  | 500      | 2,000        | 5,000    | 10,000    | 20,000    |

## 🔧 Frontend Integration

### Models

#### QuestTemplate (`lib/models/quest_template.dart`)

```dart
class QuestTemplate {
  final int id;
  final String title;
  final String description;
  final String category;        // General, Strength, Cardio, etc.
  final String difficulty;      // Beginner, Intermediate, etc.
  final int minLevel;           // e.g., 6
  final int maxLevel;           // e.g., 15
  final int xpReward;           // e.g., 110
  final int durationDays;       // e.g., 14
  final Map<String, dynamic>? targetMetrics; // JSON metrics

  Color getDifficultyColor() { /* ... */ }
}
```

#### Quest (`lib/models/quest.dart`)

```dart
class Quest {
  final int id;
  final String title;
  final String description;
  final String priority;        // Low, Medium, High, Critical
  final int xpReward;
  final bool isCompleted;
  final int? duration;          // Total seconds
  final int? totalReps;
  final double? totalWeight;
  // ... other fields
}
```

### Services

#### QuestService (`lib/services/quest_service.dart`)

**Core Methods:**

- `getAvailableQuests(userId)` - Fetch templates for user's level
- `claimQuest(userId, templateId)` - Claim a quest from template
- `getActiveQuests(userId)` - Get user's active quests
- `getCompletedQuests(userId)` - Get completed quests
- `toggleQuestStatus(userId, questId)` - Mark complete/incomplete

**Admin Method:**

- `generateQuestTemplates(...)` - Generate quest templates (admin only)

### Pages

#### AvailableQuestsPage (`lib/pages/available_quests_page.dart`)

- Displays quest templates filtered by user level
- Category filter dropdown (8 categories)
- Shows difficulty badges, XP rewards, duration
- Modal with full quest details + target metrics
- "Claim Quest" button

#### QuestsPage (`lib/pages/quests_page.dart`)

- Tabs: Active / Completed
- Sort by: Priority, Due Date, Progress
- FAB: Navigate to AvailableQuestsPage
- Refresh quests on claim/complete

#### QuestDetailPage (`lib/pages/quest_detail_page.dart`)

- View quest details
- Link/unlink exercises
- Toggle completion status
- Delete quest

#### QuestGeneratorPage (`lib/pages/admin/quest_generator_page.dart`)

- **Admin tool** for generating quest templates
- Options: Count, save to DB, variance, categories, difficulties
- Quick presets: All, Beginner, High Level, Strength+Cardio
- Shows generation results (generated, saved, duplicates)

## 🌐 API Endpoints

### User Quest Endpoints

- `GET /api/users/{userId}/quests/available` - Get available templates
- `POST /api/users/{userId}/quests/{templateId}/claim` - Claim quest
- `GET /api/users/{userId}/quests/active` - Get active quests
- `GET /api/users/{userId}/quests/completed` - Get completed quests
- `PATCH /api/users/{userId}/quests/{questId}/toggle` - Toggle completion
- `DELETE /api/users/{userId}/quests/{questId}` - Delete quest

### Admin Endpoint

- `POST /api/generate-quest-templates` - Generate templates

**Request Body:**

```json
{
  "count": 100,
  "saveToDatabase": true,
  "addVariance": true,
  "returnTemplates": false,
  "categories": ["Strength", "Cardio"],
  "difficulties": ["Intermediate", "Advanced"]
}
```

**Response:**

```json
{
  "message": "Quest templates generated and saved",
  "generated": 65,
  "savedToDb": 60,
  "duplicates": 5,
  "templates": null
}
```

## 🎮 User Flow

### 1. Level Progression

```
User starts at Level 1
↓
Sees 25 Beginner quests (Level 1-5)
↓
Claims and completes quests
↓
Gains XP → Levels up
↓
Reaches Level 6
↓
Unlocks 35 Intermediate quests (Level 6-15)
↓
Continues progression...
```

### 2. Quest Lifecycle

```
1. Browse Available Quests
   ↓
2. View Quest Details (category, difficulty, XP, metrics)
   ↓
3. Claim Quest → Added to Active Quests
   ↓
4. Link Exercises to Quest (optional)
   ↓
5. Complete Exercise Sessions
   ↓
6. Toggle Quest Completion
   ↓
7. Earn XP Reward → Level Up
   ↓
8. Unlock More Quests
```

### 3. Quest Discovery by Level

| User Level | Available Quests              |
| ---------- | ----------------------------- |
| 1          | ~25 (Beginner)                |
| 10         | ~60 (Beginner + Intermediate) |
| 20         | ~100 (+ Advanced)             |
| 40         | ~150 (+ Expert)               |
| 60+        | ALL 195+ quests               |

## 🎨 UI/UX Features

### Quest Cards

- **Difficulty Badge**: Color-coded (green → purple)
- **Category Chip**: Blue badge
- **Duration Chip**: Orange badge
- **XP Chip**: Amber badge with star icon
- **Level Range**: Gray text at bottom
- **Border**: Difficulty color, semi-transparent

### Filters

- **Category Filter**: Dropdown with 8 categories + "All"
- **Difficulty Filter**: Visual chips with tier colors
- **Pull to Refresh**: Reload available quests

### Quest Details Modal

- **Scrollable Sheet**: Draggable, 50-95% screen
- **Full Description**: Quest details
- **Target Metrics**: JSON metrics displayed as key-value pairs
- **Claim Button**: Full-width, rounded, elevated

## 🔒 Business Rules

### Level Gating

- Users can **only see quests** where `userLevel >= minLevel && userLevel <= maxLevel`
- Backend enforces this in `/quests/available` endpoint

### Duplicate Prevention

- Backend checks for duplicate quest titles before inserting
- Users **cannot claim the same active quest twice**

### Quest Completion

- Toggle completion status (active ↔ completed)
- XP rewarded on first completion only
- Completed quests move to "Completed" tab

### Template Immutability

- Users **cannot edit quest templates**
- No "Create Custom Quest" functionality
- Edit button removed from quest details

## 📈 Progression System

### XP Calculation

```
Base XP = 50
Difficulty Multiplier:
  Beginner: 1x
  Intermediate: 2x
  Advanced: 4x
  Expert: 8x
  Master: 15x

Variance (if enabled): -10 to +20

Final XP = (Base × Multiplier) + Variance
```

### Level Requirements

```
Level 2: 100 XP
Level 3: 200 XP
Level 4: 300 XP
...
Level 10: 1000 XP
Level 20: 2000 XP
...
(Linear: Level × 100 XP)
```

## 🚀 Setup Instructions

### 1. Generate Initial Templates

```
1. Open app → Settings → Quest Template Generator
2. Tap "Generate All (200+ templates)"
3. Wait for completion
4. Verify in Available Quests page
```

### 2. Test User Flow

```
1. Login as test user (Level 1)
2. Navigate to Quests → Tap +
3. See ~25 Beginner quests
4. Claim a quest
5. Verify it appears in Active Quests
6. Toggle completion
7. Check XP increase
```

### 3. Verify Level Progression

```
1. Manually set user to Level 10 in database
2. Refresh Available Quests
3. Should see Beginner + Intermediate quests (~60 total)
```

## 🎯 Future Enhancements

- [ ] Daily/Weekly quest rotation
- [ ] Seasonal event quests
- [ ] Quest rewards beyond XP (badges, items)
- [ ] Quest chains/dependencies
- [ ] Leaderboards by quest completion
- [ ] Quest recommendations based on user history
- [ ] Push notifications for quest expiry
- [ ] Quest sharing/challenges

## 📝 Files Modified/Created

### Created

- `lib/models/quest_template.dart` - Template model
- `lib/pages/available_quests_page.dart` - Browse quests
- `lib/pages/admin/quest_generator_page.dart` - Admin tool
- `QUEST_GENERATOR_GUIDE.md` - User guide
- `QUEST_SYSTEM_SUMMARY.md` - This file

### Modified

- `lib/services/quest_service.dart` - Added template methods
- `lib/pages/quests_page.dart` - Navigate to available quests
- `lib/pages/settings_page.dart` - Link to generator
- `lib/pages/quest_detail_page.dart` - Removed edit functionality

### Deleted

- `lib/pages/create_quest_page.dart` - No longer needed

---

**Version**: 1.0
**Last Updated**: October 22, 2025
**Quest Template Count**: 195+
**Difficulty Tiers**: 5
**Categories**: 8
