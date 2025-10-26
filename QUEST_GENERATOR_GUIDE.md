# Quest Template Generator - Quick Reference

## 🎯 Overview

The Quest Template Generator can create **200+ unique quest templates** with proper difficulty scaling, level gating, and category variety.

## 🚀 How to Use

### Access the Generator

1. Open the FitQuest app
2. Go to **Settings** tab
3. Scroll to **Developer Tools**
4. Tap **Quest Template Generator**

### Generate Quests

#### Option 1: Quick Presets

- **Generate All**: Creates 200+ templates covering all categories and difficulties
- **Beginner Only**: Creates 40 beginner-level quests (Level 1-5)
- **High Level Only**: Expert + Master quests for advanced players
- **Strength & Cardio**: 70 templates focused on these categories

#### Option 2: Custom Generation

1. Set **Number of Quests** (1-1000)
2. Toggle options:
   - **Save to Database**: Actually saves (vs preview only)
   - **Add Variance**: Randomizes XP ±10-20
   - **Return Templates**: Shows generated quests in response
3. Filter by **Categories** (optional)
4. Filter by **Difficulties** (optional)
5. Tap **Generate Quest Templates**

## 📊 Quest Statistics

### Categories (8 types)

- **General**: Basic exercise challenges (5 patterns)
- **Strength**: Weight training, reps (7 patterns)
- **Cardio**: Running, cycling, endurance (6 patterns)
- **Flexibility**: Yoga, stretching (4 patterns)
- **Endurance**: Stamina workouts (4 patterns)
- **Consistency**: Daily streaks (5 patterns)
- **WeightLoss**: Calorie burning (4 patterns)
- **MuscleGain**: Hypertrophy training (4 patterns)

### Difficulties (5 tiers)

| Difficulty   | Level Range | XP Multiplier | Duration | Example Quest         |
| ------------ | ----------- | ------------- | -------- | --------------------- |
| Beginner     | 1-5         | 1x (50 XP)    | 7 days   | Complete 3 exercises  |
| Intermediate | 6-15        | 2x (100 XP)   | 14 days  | Complete 10 exercises |
| Advanced     | 16-30       | 4x (200 XP)   | 21 days  | Complete 20 exercises |
| Expert       | 31-50       | 8x (400 XP)   | 30 days  | Complete 40 exercises |
| Master       | 51-100      | 15x (750 XP)  | 45 days  | Complete 60 exercises |

## 🎮 Value Scaling Examples

### Reps Scaling

- Beginner: 50 reps
- Intermediate: 500 reps
- Advanced: 2,000 reps
- Expert: 5,000 reps
- Master: 10,000 reps

### Weight Scaling

- Beginner: 1,000 kg total
- Intermediate: 5,000 kg
- Advanced: 30,000 kg
- Expert: 100,000 kg
- Master: 250,000 kg

### Duration Scaling

- Beginner: 30 minutes
- Intermediate: 120 minutes
- Advanced: 300 minutes
- Expert: 600 minutes
- Master: 1,200 minutes

## 📋 Common Use Cases

### Initial Setup

**Goal**: Populate database with all quest templates

```
Count: 1000
Save to Database: ✓
Add Variance: ✓
Return Templates: ✗
Categories: (all)
Difficulties: (all)
```

**Result**: ~200 unique templates

### Add Missing Content

**Goal**: Add only flexibility quests

```
Count: 50
Save to Database: ✓
Categories: Flexibility
Difficulties: (all)
```

**Result**: ~20 flexibility templates

### Testing/Preview

**Goal**: See what would be generated without saving

```
Count: 10
Save to Database: ✗
Return Templates: ✓
Categories: Strength
```

**Result**: Preview 10 strength templates

## ⚠️ Important Notes

1. **Duplicates**: The backend automatically skips duplicate quest titles
2. **Level Gating**: Users only see quests matching their level
3. **Progression**:
   - Level 1 user: ~25 available quests
   - Level 10 user: ~60 available quests
   - Level 40 user: ~150 available quests
   - Level 60+ user: ALL quests available

## 🔍 Response Fields

After generation, you'll see:

- **Generated**: Total templates created
- **Saved**: How many were saved to database
- **Duplicates**: How many were skipped (already exist)
- **Message**: Success/error message

## 💡 Pro Tips

1. **First Time Setup**: Use "Generate All" preset
2. **Add More Variety**: Re-run with `addVariance: true`
3. **Category Focus**: Select 2-3 categories for targeted generation
4. **Level Balancing**: Generate each difficulty separately to ensure even distribution
5. **Test Before Saving**: Use preview mode first, then enable save

## 🎯 Quest Patterns Examples

### Strength Patterns

- "Complete {reps} total reps"
- "Lift {weight}kg total weight"
- "Do {sets} sets of strength exercises"
- "Complete {count} strength training sessions"

### Cardio Patterns

- "Run/cycle for {duration} minutes"
- "Cover {distance}km distance"
- "Complete {count} cardio sessions"
- "Burn {calories} calories"

### Consistency Patterns

- "Exercise {streak} days in a row"
- "Exercise {count} times this week"
- "Don't miss a workout for {streak} days"

## 🚀 Next Steps

After generating templates:

1. Go to **Quests** tab
2. Tap **+** button
3. See your generated templates filtered by level
4. Claim quests and start completing them!

---

**Backend Endpoint**: `POST /api/generate-quest-templates`
**Frontend Service**: `QuestService.generateQuestTemplates()`
**Admin Page**: Settings → Developer Tools → Quest Template Generator
