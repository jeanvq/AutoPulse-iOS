# AutoPulse iOS

A native iOS vehicle health management app built with SwiftUI and Firebase, developed as a capstone project for the Web Development Diploma at triOS College.

## Features

- 🔐 Authentication — Email/password login and registration via Firebase Auth
- 🚗 Vehicle Management — Add, edit, and delete vehicles with VIN lookup
- ⛽ Fuel Tracking — Log fill-ups and visualize monthly spend with Swift Charts
- 🔧 Maintenance Log — Track service history with date and mileage
- 📊 Dashboard — Animated health score ring based on vehicle activity

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI (iOS 17+) |
| Language | Swift 5.9 |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Charts | Swift Charts |
| Networking | URLSession + NHTSA VIN API |
| Architecture | MVVM |

## Project Structure
AutoPulse/
├── APP/                  # App entry point
├── Views/
│   ├── Auth/             # Login, Register
│   ├── Dashboard/        # Health score
│   ├── Vehicles/         # Vehicle CRUD
│   ├── Fuel/             # Fuel records
│   └── Maintenance/      # Maintenance log
├── ViewModels/           # ObservableObject classes
├── Models/               # Data models
└── Services/             # API & Firestore services

## Setup

1. Clone the repo
2. Open `AutoPulse.xcodeproj` in Xcode 15+
3. Add your own `GoogleService-Info.plist` from Firebase Console
4. Build and run on simulator (iOS 17+)

> ⚠️ `GoogleService-Info.plist` is not included in the repo for security reasons.

## Documents

- [Capstone Proposal](docs/AutoPulse_iOS_Capstone_Proposal.docx)

## Author

**Jeancarlo Velez**
[jeancarlodev.com](https://jeancarlodev.com) · [GitHub](https://github.com/jeanvq)

---
*triOS College — Web Development Diploma — iOS Development Capstone — 2026*
EO
git add README.md
git commit -m "Add README"
git push
