# UAS Flutter - C14220119 (Daily Planner App)
Aplikasi Flutter untuk tugas akhir mata kuliah AMBW.

A Flutter application for managing daily tasks with user authentication and cloud database storage using Supabase.

## Features

- **Authentication**: Sign up, sign in, and sign out with email/password
- **Cloud Database**: Tasks stored in Supabase database with user-specific data
- **Session Persistence**: Users stay logged in using SharedPreferences
- **Get Started Screen**: First-time app opening experience
- **Task Management**: Add, edit, delete, and mark tasks as complete
- **Category Organization**: Categorize tasks (Work, Personal, Health, etc.)
- **Date Selection**: View and manage tasks by specific dates
- **Modern UI**: Clean, intuitive interface with Google Fonts

## Screenshots

1. **Get Started Screen**: Welcome screen shown on first app launch
2. **Login/Signup**: Authentication screens with validation
3. **Home Screen**: Main dashboard showing tasks with statistics

## Setup Instructions

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Supabase account

### 1. Clone the Repository

```bash
git clone <repository-url>
cd uas_c14220119
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to Settings > API in your Supabase dashboard
3. Copy your project URL and anon key
4. Update `lib/main.dart` with your credentials:

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 4. Database Schema

Create the following table in your Supabase SQL editor:

```sql
-- Create tasks table
CREATE TABLE tasks (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  category TEXT NOT NULL,
  date_time TIMESTAMPTZ NOT NULL,
  is_completed BOOLEAN DEFAULT FALSE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Create policy to allow users to only see their own tasks
CREATE POLICY "Users can only see their own tasks" ON tasks
  FOR ALL USING (auth.uid() = user_id);
```

### 5. Run the Application

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── task.dart            # Task data model
├── providers/
│   ├── auth_provider.dart   # Authentication state management
│   └── task_provider.dart   # Task state management
├── screens/
│   ├── get_started_screen.dart
│   ├── home_screen.dart
│   └── auth/
│       ├── login_screen.dart
│       └── signup_screen.dart
├── services/
│   ├── auth_service.dart    # Supabase authentication
│   └── firestore_service.dart # Supabase database operations
└── widgets/
    ├── add_task_dialog.dart # Task creation/editing dialog
    └── task_card.dart       # Individual task display
```

## Demo Credentials

For testing purposes, you can create a new account or use:

**Note**: Please create your own test account through the signup process.

Example credentials format:

- Email: test@example.com
- Password: password123

## Features Implemented

### Authentication (20 points)

- ✅ Supabase Auth integration
- ✅ Sign Up, Sign In, Sign Out functionality
- ✅ Input validation with error messages
- ✅ Password visibility toggle

### Cloud Database (20 points)

- ✅ Supabase Database integration
- ✅ User-specific data storage using UID
- ✅ Real-time data updates
- ✅ CRUD operations for tasks

### Session Persistence (20 points)

- ✅ SharedPreferences for login state
- ✅ Automatic login on app restart
- ✅ Secure session management

### Get Started Screen (20 points)

- ✅ First-time user experience
- ✅ Only shown on initial app install
- ✅ Smooth navigation to auth screens

### Design & Navigation (10 points)

- ✅ Clean, modern UI design
- ✅ Intuitive navigation flow
- ✅ Provider state management
- ✅ Responsive design elements

### Documentation (10 points)

- ✅ Comprehensive README
- ✅ Setup instructions
- ✅ Screenshot documentation
- ✅ Code structure explanation

## Dependencies

- `supabase_flutter`: Supabase client for authentication and database
- `provider`: State management solution
- `shared_preferences`: Local data persistence
- `google_fonts`: Typography enhancement
- `intl`: Date/time formatting

## Task Categories

- Work: Professional tasks and meetings
- Personal: Personal activities and errands
- Health: Exercise, medical appointments
- Education: Learning and study activities
- Shopping: Purchase lists and errands
- Other: Miscellaneous tasks

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is created for educational purposes as part of a university assignment.
