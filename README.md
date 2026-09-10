# AutoPulse iOS

> **A native iOS vehicle health management app** built with SwiftUI and Firebase, developed as a capstone project for the Web Development Diploma at triOS College.

![iOS](https://img.shields.io/badge/iOS-17%2B-blue) ![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?logo=swift&logoColor=white) ![SwiftUI](https://img.shields.io/badge/SwiftUI-modern-green)

---

## 📱 Features

- 🔐 **Authentication** — Email/password + Sign in with Apple via Firebase Auth
- 🚗 **Vehicle Management** — Add, edit, and delete vehicles with VIN lookup (NHTSA API)
- ⛽ **Fuel Tracking** — Log fill-ups and visualize monthly spend with Swift Charts
- 🔧 **Maintenance Log** — Track service history with date and mileage
- 📊 **Dashboard** — Animated health score ring based on vehicle activity
- 🤖 **AI Scanner** — Claude AI diagnoses dashboard warning lights from photos
- 🌤️ **Weather Alerts** — Real-time weather tips based on your location
- 🌎 **Bilingual** — Full English/Spanish localization (auto-detects iPhone language)

---

## 📸 Screenshots

<div align="center">

### Authentication & Dashboard
<p>
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro - 2026-09-10 at 19.26.34.png" width="18%" alt="Login Screen" />
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro - 2026-09-10 at 19.26.45.png" width="18%" alt="Dashboard" />
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro - 2026-09-10 at 19.26.49.png" width="18%" alt="Health Score" />
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro - 2026-09-10 at 19.26.54.png" width="18%" alt="Weather Alerts" />
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro - 2026-09-10 at 19.26.59.png" width="18%" alt="Vehicle List" />
</p>

### Features in Action
<p>
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro - 2026-09-10 at 19.27.51.png" width="18%" alt="Fuel Tracking" />
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro - 2026-09-10 at 19.27.54.png" width="18%" alt="Maintenance Log" />
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro - 2026-09-10 at 19.27.57.png" width="18%" alt="AI Scanner" />
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro - 2026-09-10 at 19.28.01.png" width="18%" alt="Settings" />
</p>

</div>

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI Framework** | SwiftUI (iOS 17+) |
| **Language** | Swift 5.9 |
| **Architecture** | MVVM |
| **Authentication** | Firebase Authentication |
| **Database** | Cloud Firestore |
| **Charts** | Swift Charts |
| **Networking** | URLSession + NHTSA VIN API |
| **AI Integration** | Claude Haiku (Anthropic API) |
| **Weather Data** | Open-Meteo API |

---

## 📁 Project Structure

```
AutoPulse/
├── APP/                      # App entry point & environment setup
├── Views/
│   ├── Auth/                # Login & Registration
│   ├── Dashboard/           # Health score + Weather alerts
│   ├── Vehicles/            # Vehicle CRUD operations
│   ├── Fuel/                # Fuel records & Charts
│   ├── Maintenance/         # Service history log
│   └── AIScannerView/       # AI warning light scanner
├── ViewModels/              # ObservableObject classes
├── Models/                  # Data models
└── Services/                # API, Firestore, Weather, Health Score
```

---

## 🚀 Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+
- CocoaPods (if applicable)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/jeanvq/AutoPulse-iOS.git
   cd AutoPulse-iOS
   ```

2. **Open in Xcode**
   ```bash
   open AutoPulse.xcodeproj
   ```

3. **Configure Firebase**
   - Download `GoogleService-Info.plist` from [Firebase Console](https://console.firebase.google.com)
   - Add it to the Xcode project (⚠️ not included in repo for security)

4. **Set Anthropic API Key**
   - Go to **Xcode → Product → Scheme → Edit Scheme**
   - Navigate to **Run → Arguments**
   - Add environment variable: `ANTHROPIC_API_KEY` with your API key

5. **Build & Run**
   - Select an iOS 17+ simulator or device
   - Press `Cmd + R` to build and run

> ⚠️ **Security Note:** `GoogleService-Info.plist` and API keys are not included in the repository for security reasons.

---

## 📚 Documentation

- [Capstone Proposal](docs/AutoPulse_iOS_Capstone_Proposal.docx)

---

## 👨‍💻 About the Developer

**Jeancarlo Ricardo Velásquez**

- 🌐 Portfolio: [jeancarlodev.com](https://jeancarlodev.com)
- 💻 GitHub: [@jeanvq](https://github.com/jeanvq)
- 🔗 LinkedIn: [jeancarlo-ricardo-392b4a365](https://linkedin.com/in/jeancarlo-ricardo-392b4a365)

---

## 📄 License

This project was developed as a capstone project for the **Web Development Diploma** at **triOS College** (2026).

---

<div align="center">

**Built with ❤️ | iOS Development Capstone Project**

*triOS College — Web Development Diploma*

</div>
