/// All user-facing strings in one place.
///
/// Keeping strings here (instead of inline in widgets) serves two purposes:
/// 1. Easy to find and update copy without digging through widget code.
/// 2. Ready for internationalization (i18n) in Phase 5 — swap this class
///    for generated ARB strings without touching any widget.
class AppStrings {
  AppStrings._();

  // App identity
  static const appName = 'Jarvis';
  static const appTagline = 'Your personal productivity OS';

  // Generic UI
  static const loading = 'Loading...';
  static const error = 'Something went wrong';
  static const retry = 'Retry';
  static const cancel = 'Cancel';
  static const save = 'Save';
  static const delete = 'Delete';
  static const confirm = 'Confirm';
  static const viewAll = 'View all';

  // Auth
  static const signIn = 'Sign In';
  static const signOut = 'Sign Out';
  static const createAccount = 'Create Account';
  static const email = 'Email';
  static const password = 'Password';
  static const fieldRequired = 'This field is required';
  static const passwordTooShort = 'Password must be at least 6 characters';
  static const authError = 'Authentication failed';
  static const noAccountSignUp = "Don't have an account? Sign Up";
  static const haveAccountSignIn = 'Already have an account? Sign In';

  // Navigation / sections
  static const today = 'Today';
  static const goals = 'Goals';
  static const projects = 'Projects';
  static const tasks = 'Tasks';
  static const subtasks = 'Subtasks';
  static const profile = 'Profile';
  static const activeGoals = 'Active Goals';
  static const dueToday = 'Due Today';
  static const addNew = 'Add New';
  static const pending = 'Pending';
  static const completed = 'Completed';

  // Greetings
  static const goodMorning = 'Good morning';
  static const goodAfternoon = 'Good afternoon';
  static const goodEvening = 'Good evening';

  // Today screen
  static const tasksDoneToday = 'tasks done today';
  static const allDoneToday = 'All done for today! 🎉';
  static const noGoalsActiveYet = 'No active goals yet.';
  static const nothingScheduledToday =
      'Nothing scheduled today.\nTap + to add a task.';

  // Profile screen
  static const streakComingInPhase2 = 'Streaks coming in Phase 2';
  static const thisWeek = 'This week';
  static const analyticsComingInPhase2 = 'Analytics coming in Phase 2';

  // Goals
  static const newGoal = 'New Goal';
  static const goalTitle = 'Title';
  static const goalIntention = 'Why this goal?';
  static const noGoalsYet = 'No goals yet. Tap + to create one.';
  static const noActiveGoals = 'No active goals.';
  static String priority(int p) => 'Priority: $p';

  // Projects
  static const newProject = 'New Project';
  static const projectTitle = 'Project title';
  static const noProjectsYet = 'No projects yet. Tap + to add one.';

  // Subtasks
  static const newSubtask = 'New Subtask';
  static const subtaskTitle = 'Subtask title';
  static const noSubtasksYet = 'No subtasks yet. Tap + to add one.';

  // Tasks
  static const newTask = 'New Task';
  static const taskTitle = 'Task title';
  static const noTasksYet = 'No tasks yet. Tap + to create one.';
  static const noTasksDueToday = 'Nothing due today.';

  // Phase 0 placeholder (kept for existing widget test)
  static const phase0Label = 'Phase 0 — Foundation';
}
