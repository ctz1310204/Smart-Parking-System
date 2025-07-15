# 🚗 Smart Parking System – IoT Project

A full-stack IoT-based Smart Parking System that integrates embedded hardware, cloud database, and mobile application to provide a real-time solution for managing parking slots.

> 📌 This project was developed as part of a university course and showcases end-to-end integration of IoT hardware, backend automation, and mobile app development.

---

## 📂 Project Structure

```
Smart-Parking-System/
└── iot/
    ├── flutter_app/                 # Flutter mobile app
    ├── node_red_smartparking_final.json     # Node-RED flow
    ├── firebase_smartparking_final.json     # Firebase structure
    ├── README.md                    # This file
```

---

## 📱 Mobile App – Flutter

The Flutter app allows users to:

- View available parking slots in real-time  
- Book/reserve slots via Firebase Realtime Database  
- Receive feedback on parking status (occupied, empty)

**Tech used:** Flutter, Dart, Firebase

### 🚀 To Run:

```bash
cd iot/flutter_app
flutter pub get
flutter run
```

> ⚠️ You will need your own `google-services.json` to connect to Firebase.

---

## 🔁 Node-RED Flow

- Reads sensor data from ESP8266 (IR and RFID)
- Controls servo motor for gate operation
- Updates Firebase Realtime Database with spot status and reservation details
- Receives data via HTTP POST from ESP8266 modules

**File:** [`node_red_smartparking_final.json`](iot/node_red_smartparking_final.json)

### 🛠 To Use:

1. Open Node-RED  
2. Import the JSON flow  
3. Deploy and test with HTTP requests from your device

---

## 🔗 Firebase Realtime Database

Used to store:

- Current spot status (occupied/empty)  
- Vehicle RFID and time in/out  
- User reservations and booking times

**File:** [`firebase_smartparking_final.json`](iot/firebase_smartparking_final.json)

### 🧱 Structure Sample:

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

## 👨‍💻 Author

**Chu Tâm Vũ**  
GitHub: [@ctz1310204](https://github.com/ctz1310204)

---

## 📚 License

This project is for educational purposes only. Feel free to use and adapt it with credit.
