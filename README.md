# Smart Parking System – IoT Project

A full-stack IoT-based Smart Parking System that integrates embedded hardware, cloud database, and mobile application to provide a real-time solution for managing parking slots.

> This project was developed as part of a university course and showcases end-to-end integration of IoT hardware, backend automation, and mobile app development.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Technologies Used](#technologies-used)
- [Features](#features)
- [Architecture and Components](#architecture-and-components)
- [Node-RED Flow](#node-red-flow)
- [Firebase Structure](#firebase-structure)
- [Mobile App](#mobile-app)
- [Installation & Running](#installation--running)
- [Author](#author)
- [License](#license)

---

## Project Overview

This system allows vehicles to enter and exit a parking lot automatically using ESP8266-based hardware, IR sensors, RFID readers, and servo motors. It updates status in Firebase Realtime Database and reflects changes instantly in a Flutter-based mobile application.

Developed from **February 2025 – May 2025**, it demonstrates real-time hardware–cloud–app integration.

---

## Technologies Used

- **Hardware:** ESP8266, IR Sensor, RFID Reader, Servo Motor
- **Backend:** Node-RED, Firebase Realtime Database
- **Mobile:** Flutter, Dart
- **Communication:** HTTP, JSON

---

## Features

- Real-time parking slot status detection via sensors
- RFID-based vehicle identification
- Servo control for automatic gate opening
- Firebase cloud integration for real-time data sync
- Flutter mobile app for user interaction and monitoring

---

## Architecture and Components

- **ESP8266 + IR/RFID:** Detect car presence and read RFID
- **Node-RED:** Receives data, handles logic, updates Firebase
- **Firebase:** Stores slot status, timestamps, reservations
- **Flutter App:** Retrieves real-time data and allows user interaction

```
Vehicle → ESP8266 → Node-RED → Firebase → Flutter App
```

---

## Node-RED Flow

**File:** [`node_red_smartparking_final.json`](iot/node_red_smartparking_final.json)

### Key Logic:
- HTTP endpoints for ESP8266 to report entry/exit
- Parses RFID and IR signals
- Updates `spots` and `reservations` in Firebase
- Uses function nodes for conditional logic and formatting

---

## Firebase Structure

**File:** [`firebase_smartparking_final.json`](iot/firebase_smartparking_final.json)

### Sample:
```json
{
  "spots": {
    "A1": {
      "status": "occupied",
      "rfid_actual": "1234567890",
      "time_in_actual": "2025-07-15 08:00",
      "time_out_actual": null
    }
  },
  "reservations": {
    "user_uid": {
      "spot_id": "A1",
      "start_time": "...",
      "end_time": "..."
    }
  }
}
```

---

## Mobile App

**Location:** [`iot/flutter_app/`](iot/flutter_app/)

### Built with:
- Flutter, Dart, Firebase Realtime DB

### Features:
- View live parking spot status
- Make and cancel reservations
- Connects directly to Firebase using streams

---

## Installation & Running

### Run Flutter App:
```bash
cd iot/flutter_app
flutter pub get
flutter run
```

> Ensure you provide your own `google-services.json` for Firebase integration.

### Use Node-RED Flow:
1. Open Node-RED
2. Import `node_red_smartparking_final.json`
3. Deploy and test with HTTP from ESP8266

---

## Author

**Chu Tâm Vũ**  
GitHub: [@ctz1310204](https://github.com/ctz1310204)

---

## License

This project is for educational purposes only. Feel free to use and adapt it with credit.
