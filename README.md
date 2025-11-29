# 📚 SkillCast – A Modern Learning Platform (Flutter + Firebase)

SkillCast is a complete learning management platform built using Flutter and Firebase.  
Students can browse courses, enroll, write reviews, and manage their profiles.  
Admins and instructors can add, edit, and delete courses through privileged access.  
This repository contains the full cross-platform Flutter application.

---

## 🚀 Features

### 👨‍🎓 Student Features
- Register & Login with Firebase Authentication
- Browse all published courses
- View course details with description + instructor info
- Read course reviews (even before enrolling)
- Enroll & unenroll from courses
- Access enrolled courses via “My Courses”
- Write reviews after enrollment
- Edit profile (name, bio, avatar)

### 👨‍🏫 Admin / Instructor Features
- Add new courses
- Edit existing courses
- Delete courses
- Manage course publication status

### 🔧 Backend (Firebase)
- Firebase Authentication  
- Firestore Database  
- Firebase Storage  
- Firestore Security Rules  

---

## 🛠️ Tech Stack

### Frontend
- Flutter (Dart)
- Material UI Widgets
- Provider / Bloc / Riverpod (based on your implementation)
- Fully responsive (Android, iOS, Web, Desktop)

### Backend
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firestore Security Rules

---

## 📘 API Documentation (Full)

The complete API design, data model, Firestore rules, screen-to-API mapping, and architecture description can be found here:

👉 

This includes:
- Firestore collection schema  
- Authentication flow  
- Enrollment flow  
- Reviews flow  
- Firestore rules explanation  
- Architecture diagram  
- Screens → API mapping  

---

## 🧩 Installation & Setup Guide

### 1.Clone the repository

git clone https://github.com/Aryan521rajput/skillcast.git
cd skillcast

2.Install all dependencies
flutter pub get

3.Run on device or emulator
flutter run

### Running the iOS Version

Since iOS requires macOS + Xcode, follow these steps on a Mac:

Step 1 — Install dependencies
flutter pub get

Step 2 — Build the iOS project
flutter build ios

Step 3 — Open in Xcode
open ios/Runner.xcworkspace

Step 4 — Build & run

Select a simulator or physical iPhone
Click Run (Play button)
