# Tictactoe
A simple, clean, and customizable **Tic Tac Toe** game built with **Flutter**. This app supports **Single Player (vs CPU)** with difficulty levels and a smooth, responsive UI.

## 🎮 Features

- 🧠 **Single Player** mode with 3 difficulty levels:
  - Easy (User-friendly)
  - Medium (Balanced)
  - Hard (Challenging AI)
- 🎨 Modern and minimal UI
- 💾 Clean code structure with reusable components
- 📱 Fully responsive on different screen sizes
- 🖼️ Custom splash screen with logo

## 📁 File Structure

```

tictactoe/
│
├── android/                # Android-specific config
├── assets/                 # Assets used in the project
├── ios/                    # iOS-specific config
├── lib/
│   ├──Modes
│     ├── easyMode.dart
│     ├── mediumMode.dart
│     └──hardMode.dart
│   ├── homeScreen.dart     # Main menu screen
│   ├── splashscreen.dart   # Custom splash screen with text/logo
│   ├── computer.dart       # CPU logic (Easy, Medium, Hard)
│   └── main.dart           # Entry point
│
├── pubspec.yaml            # Project metadata and dependencies
└── README.md               # You're here!

````

---

## ▶️ How to Run

### 1. **Clone the repo**
```bash
git clone https://github.com/abhishek-2006/Tictactoe.git
cd Tictactoe
````

### 2. **Install dependencies**

```bash
flutter pub get
```

### 3. **Run the app**

```bash
flutter run
```

> 💡 Make sure you have Flutter installed: [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

## ⚙️ Requirements

* Flutter SDK (latest stable)
* Android Studio / VS Code
* Android/iOS emulator or physical device

## 📄 License

This project is licensed under the **MIT License**. You are free to use, modify, and distribute it.

## 👨‍💻 Developer

Made with ❤️ by **Abhishek Shah**

⭐ Give this project a star if you found it helpful!
