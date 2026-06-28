# 🧠 Lie Detector AI

> An interactive, AI-powered "lie detector" game that analyzes facial micro-expressions and biometric signals in real time.

![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white)
![ML Kit](https://img.shields.io/badge/Google%20ML%20Kit-4285F4?logo=google&logoColor=white)

## About

**Lie Detector AI** is an entertainment app that simulates a biometric lie-detection experience. It uses **Google ML Kit** for real-time face tracking and micro-expression detection, and fuses signals from the device's sensors (accelerometer / PPG) into a multi-layer scoring algorithm.

> ⚠️ Built for fun and as a computer-vision/sensor-fusion experiment — not a real medical or forensic tool.

## Features

- 👁️ Real-time face tracking & micro-expression detection (Google ML Kit)
- 📈 Sensor fusion (accelerometer + heart-rate / PPG signals)
- 🧩 Multi-stage analysis algorithm
- 📳 Voice & vibration-based interaction

## Tech stack

- **Flutter** (Dart)
- **Google ML Kit** (face detection)
- **Device sensors** (camera, accelerometer, PPG)

## Run locally

```bash
git clone https://github.com/ismetguler/Lie-Detector-AI-Game.git
cd Lie-Detector-AI-Game
flutter pub get
flutter run
```

---
Made by [İsmet Güler](https://github.com/ismetguler) · [Portfolio](https://ismetguler.github.io)
