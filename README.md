# ALU Student Academic Platform


A comprehensive mobile application designed to help African Leadership University students manage their academic responsibilities, track assignments, monitor attendance, and organize their class schedules.


## 📂 Project Structure


```
lib/
├── main.dart                 # Application entry point
├── screens/
│   ├── dashboard_screen.dart # Home dashboard
│   ├── assignments_screen.dart # Assignment management
│   └── schedule_screen.dart  # Session scheduling
├── models/
│   ├── assignment.dart       # Assignment data model
│   ├── session.dart          # Session data model
│   └── attendance.dart       # Attendance data model
├── services/
│   ├── storage_service.dart  # Data persistence logic
│   └── attendance_service.dart # Attendance calculations
└── widgets/
    ├── assignment_card.dart  # Reusable assignment widget
    ├── session_card.dart     # Reusable session widget
    └── dashboard_metric.dart # Dashboard metric widgets
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
   git clone [your-repository-url]
   cd alu-student-platform
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
