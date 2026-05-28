# NurseCareGo - On Demmand Home Healthcare App 

A cross-platform mobile application built with Flutter and Firebase that bridges 
the gap between patients and qualified nurses for home healthcare services in Pakistan.

## About The Project

NurseCareGo allows patients to browse verified nurses, view their profiles, 
and send hiring requests based on their healthcare needs. Nurses can manage 
incoming requests, accept or reject bookings, and communicate with patients 
directly through the app.

This project was developed as a Final Year Project.

---

## Features

### Patient Side
- Register and login securely with email and password
- Browse a list of verified nurses with search and filter (gender, availability)
- View detailed nurse profiles including qualifications, years of expexperience and hourly rate etc
- Book a nurse by selecting date, time and number of hours
- Automatic total fee calculation based on hourly rate
- Real-time booking history with status updates (Pending, Accepted, Rejected)
- Cancel pending booking requests
- Chat with nurse directly through in-app messaging
- Call nurse via phone
- View nurse's work location on Google Maps
  
### Nurse Side  
- Register and login securely with email and password
- View dashboard with pending request count in real time
- Browse and manage all incoming hiring requests
- View detailed patient information before accepting
- Accept or reject booking requests with confirmation
- Chat with patient directly through in-app messaging
- Call patient via phone
- View patient's home location on Google Maps
  
### General
- Role-based navigation (Patient / Nurse)
- Real-time data updates using Firebase Realtime Database
- Secure Firebase Authentication
- Image upload via Cloudinary API
- Form validation throughout the app
- Graceful error handling with retry support
- Internet timeout detection on all screens
- Soft delete for booking records
  
---

## Tech Stack
* **Frontend:** [Flutter](https://flutter.dev) (UI Toolkit)
* **Backend:** [Firebase](https://firebase.google.com) (Auth, Realtime Database)
* **Language:** [Dart](https://dart.dev) 
* **State Management:** setState + StreamBuilder + FutureBuilder
* **Architecture:** Service Layer Pattern
---

### Getting Started

### Prerequisites
Make sure you have the following installed:
- [Flutter SDK](https://docs.flutter.dev/install) (3.x or above)
- [Android Studio](https://developer.android.com/studio/install) or [VS Code](https://code.visualstudio.com/download)
- A Firebase project set up at [console.firebase.google.com](https://console.firebase.google.com)
    
### Clone The Repository
```bash 
git clone https://github.com/Jameel-Shah/Nurse_Care_Go_App.git
```

### Firebase Setup

This project requires your own Firebase configuration. The `google-services.json` 
and `firebase_options.dart` files are excluded from this repository for security.

1. Go to [Firebase Console](https://console.firebase.google.com).
2. Create a new project
3. Add an Android app or an IOS app and download `google-services.json`
4. Place it in `android/app/`
5. Enable the following Firebase services:
   - Authentication (Email/Password)
   - Realtime Database

### Install Dependencies

```bash
flutter pub get
```

### Run The App
```bash
flutter run
```

---

## Known Limitations

- Currently supports Pakistani phone number format
- Web support is limited (primarily built for Android)
- Chat feature requires both users to be registered

---


## Author
** M Jameel Ur Rehman Shah**
Final Year Project - [University Of Agriculture Faisalabad]

---

## License

This project is for academic purposes only.

