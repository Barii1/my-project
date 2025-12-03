# REVERT INSTRUCTIONS

This file contains instructions to revert the app to its state BEFORE the demo changes.

## Files Modified for Demo:

1. **lib/providers/stats_provider.dart**
   - Added: Dynamic weekly data, quiz integration, badge system
   - Original: Simple static data with basic setters

2. **lib/screens/daily_quiz_screen.dart**
   - Added: Visual feedback, XP rewards, StatsProvider integration
   - Original: Simple quiz with basic score display

3. **lib/screens/community_modern.dart**
   - Added: Auto-updating timer, dynamic rankings
   - Original: Static mock leaderboard data

4. **lib/screens/progress_screen.dart**
   - Added: StatsProvider integration, dynamic data
   - Original: Static const data display

5. **lib/chatbot.dart**
   - Modified: Enhanced UI, PDF/image support (current changes)
   - Original: Simple chat interface

## To Revert (Manual Steps):

### Option 1: Git Revert (Recommended if using Git)
```bash
git log --oneline  # Find commit before demo changes
git revert <commit-hash>
```

### Option 2: Restore from Backup
If you created a backup before demo changes:
```bash
# Restore each file from backup
cp backup/stats_provider.dart lib/providers/
cp backup/daily_quiz_screen.dart lib/screens/
cp backup/community_modern.dart lib/screens/
cp backup/progress_screen.dart lib/screens/
cp backup/chatbot.dart lib/
```

### Option 3: Manual Revert (Specific Changes)

**1. stats_provider.dart** - Remove demo features:
- Remove: `simulateProgress()`, `completeQuiz()`, dynamic weekly data
- Keep: Basic setters only

**2. daily_quiz_screen.dart** - Simplify:
- Remove: StatsProvider integration, visual feedback
- Keep: Basic quiz functionality

**3. community_modern.dart** - Remove auto-updates:
- Remove: Timer, dynamic point changes
- Keep: Static mock data methods

**4. progress_screen.dart** - Use static data:
- Remove: Consumer<StatsProvider>
- Restore: Static const lists for weeklyData, badges, skillTree

**5. chatbot.dart** - Restore if needed:
- Revert to version before PDF/image additions (current changes)

## Quick Revert Checklist:

- [ ] Remove Timer from community_modern.dart
- [ ] Remove StatsProvider.completeQuiz() calls
- [ ] Restore static data in progress_screen.dart
- [ ] Remove visual feedback from daily_quiz_screen.dart
- [ ] Test app runs without demo features

## Notes:
- Demo changes are isolated to specific methods
- Core app functionality unchanged
- All changes are reversible
- Firebase/OpenAI integration unchanged
