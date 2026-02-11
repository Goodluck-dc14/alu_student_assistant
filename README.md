# ALU Student Academic Platform


A comprehensive mobile application designed to help African Leadership University students manage their academic responsibilities, track assignments, monitor attendance, and organize their class schedules.


## 📂 Project Structure


```
lib/
├── main.dart                     # Application entry point
├── core/
│   ├── constants/
│   │   └── attendance_constants.dart  # Attendance-related constants
│   └── theme/
│       ├── app_colors.dart       # Centralised color definitions
│       └── app_theme.dart        # Theme configuration
├── data/
│   ├── assignment_repository.dart # Data access for assignments
│   └── attendance_repository.dart # Data access for attendance
├── models/
│   ├── academic_session.dart     # Academic session model
│   ├── assignment.dart           # Assignment data model
│   └── attendance_record.dart    # Attendance record model
├── providers/
│   └── session_provider.dart     # App-wide session state/provider
├── services/
│   └── attendance_service.dart   # Attendance business logic
├── features/
│   ├── assignments/
│   │   ├── assignment_form_screen.dart  # Assignment creation/editing
│   │   ├── assignments_screen.dart      # Assignments listing
│   │   └── widgets/
│   │       └── assignment_list_item.dart # Assignment list item widget
│   └── attendance/
│       └── widgets/
│           ├── attendance_history_section.dart  # Attendance history UI
│           ├── attendance_metric_card.dart      # Attendance metric cards
│           └── attendance_warning_banner.dart   # Attendance warning banner
└── screens/
    ├── app_shell.dart            # App shell/navigation container
    ├── root_shell.dart           # Root navigation shell
    ├── login_screen.dart         # Authentication screen
    ├── dashboard/
    │   ├── dashboard_screen.dart # Home dashboard
    │   └── dashboard_view_model.dart # Dashboard state & logic
    ├── assignments/
    │   └── assignments_screen.dart   # Assignments screen (shell version)
    ├── schedule/
    │   └── schedule_screen.dart  # Schedule view (nested route)
    └── schedule_screen.dart      # Legacy/global schedule screen
```


## 🚀 Getting Started


### Prerequisites
- Flutter SDK (version 3.0 or higher)
- Dart SDK (version 2.17 or higher)
- Android Studio / VS Code with Flutter extensions
- iOS Simulator (for Mac) or Android Emulator


### Installation


1. **Clone the repository**
   ```bash
   git clone https://github.com/Goodluck-dc14/alu_student_assistant.git
   cd alu_student_assistant
   ```


2. **Install dependencies**
   ```bash
   flutter pub get
   ```


3. **Run the application**
   ```bash
   # For Android emulator
   flutter run
   
   # For iOS simulator (Mac only)
   flutter run -d ios
   
   # For specific device
   flutter devices
   flutter run -d [device-id]
   ```
