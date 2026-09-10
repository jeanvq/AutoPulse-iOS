# AutoPulse iOS

A native iOS vehicle health management app built with SwiftUI and Firebase, developed as a capstone project for the Web Development Diploma at triOS College.

## Screenshots

<p float="left">
  <img src="screenshots/onboarding.png" width="19%" />
  <img src="screenshots/login.png" width="19%" />
  <img src="screenshots/dashboard.png" width="19%" />
  <img src="screenshots/vehicles.png" width="19%" />
  <img src="screenshots/fuel.png" width="19%" />
</p>

## Features

- 🔐 **Authentication** — Email/password + Sign in with Apple via Firebase Auth
- 🚗 **Vehicle Management** — Add, edit, and delete vehicles with VIN lookup (NHTSA API)
- ⛽ **Fuel Tracking** — Log fill-ups and visualize monthly spend with Swift Charts
- 🔧 **Maintenance Log** — Track service history with date and mileage
- 📊 **Dashboard** — Animated health score ring based on vehicle activity
- 🤖 **AI Scanner** — Claude AI diagnoses dashboard warning lights from photos
- 🌤️ **Weather Alerts** — Real-time weather tips based on your location
- 🌎 **Bilingual** — Full English/Spanish localization (auto-detects iPhone language)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI (iOS 17+) |
| Language | Swift 5.9 |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Charts | Swift Charts |
| Networking | URLSession + NHTSA VIN API |
| AI | Claude Haiku (Anthropic API) |
| Weather | Open-Meteo API |
| Architecture | MVVM |

## Project Structure

AutoPulse/
├── APP/ # App entry point
├── Views/
│ ├── Auth/ # Login, Register
│ ├── Dashboard/ # Health score + weather
│ ├── Vehicles/ # Vehicle CRUD
│ ├── Fuel/ # Fuel records + charts
│ ├── Maintenance/ # Maintenance log
│ └── AIScannerView # AI warning light scanner
├── ViewModels/ # ObservableObject classes
├── Models/ # Data models
└── Services/ # API, Firestore, Weather, Health Score


## Setup

1. Clone the repo
2. Open `AutoPulse.xcodeproj` in Xcode 15+
3. Add your own `GoogleService-Info.plist` from Firebase Console
4. Add `ANTHROPIC_API_KEY` in Xcode → Product → Scheme → Edit Scheme → Environment Variables
5. Build and run on simulator (iOS 17+)

> ⚠️ `GoogleService-Info.plist` is not included in the repo for security reasons.

## Documents

- [Capstone Proposal](docs/AutoPulse_iOS_Capstone_Proposal.docx)

## Author

**Jeancarlo Ricardo Velásquez**  
[jeancarlodev.com](https://jeancarlodev.com) · [GitHub](https://github.com/jeanvq) · [LinkedIn](https://linkedin.com/in/jeancarlo-ricardo-392b4a365)

---
*triOS College — Web Development Diploma — iOS Development Capstone — 2026*
