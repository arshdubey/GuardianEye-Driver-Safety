👁️ GuardianEye: Edge-AI Driver Safety Ecosystem

**GuardianEye** is a complete, full-stack Edge-AI ecosystem designed to monitor driver distraction and automate dashcam recording. It operates completely offline, processing heavy computer vision algorithms directly on-device with zero cloud latency.

This repository contains both components of the ecosystem:
1. **`driver_detection_mobile/`** - The native Android app (Smart Dashcam).
2. **`driver_detection/`** - The compiled Python web analytics dashboard.

---

## ✨ Key Features

### 📱 The Mobile App (Android)
* **Real-Time Distraction AI:** Uses Google ML Kit to map 468 facial landmarks locally. It tracks head pitch/yaw and eye closure probability to detect if a driver is asleep, looking at their phone, or distracted.
* **Zero-Lag Dashcam Engine:** Features a highly optimized, custom multi-threaded buffer that pulls raw YUV camera bytes and pipes them directly into an FFmpeg encoder, generating seamless 15-FPS MP4 dashcam footage without blocking the UI thread.
* **Dynamic Calibration:** Sleek UI sliders allow the driver to precisely calibrate the strictness of the AI thresholds to avoid false positives (e.g., squinting in sunlight).

### 🌐 The Web Dashboard (Python)
* **Standalone Analytics:** A fully compiled Python web dashboard that boots a localized server to analyze AI metrics and review footage.
* **Plug & Play:** Packaged as a single `.exe` executable using PyInstaller. No Python installation or environment setup is required to run the dashboard.

---

## 🛠️ Tech Stack

**Mobile App:**
* **Framework:** Flutter / Dart
* **Edge AI:** Google ML Kit (Face Detection API)
* **Video Processing:** FFmpeg (Raw Binary Encoding)
* **Camera Architecture:** Custom YUV420 to RGB memory pipelines

**Web Dashboard:**
* **Backend:** Python
* **Web Framework:** Streamlit / Flask
* **Compilation:** PyInstaller

---

## 🚀 Installation & Usage

### Running the Mobile App
1. Download the `app-release.apk` (or build it yourself by navigating to `driver_detection_mobile/` and running `flutter build apk`).
2. Install the APK on any Android 8.0+ device.
3. Mount the phone on your car dashboard, calibrate the AI sliders, and hit **Start Monitoring**.

### Running the Web Dashboard
1. Download the `Driver_Dashboard_Final.zip` archive from the releases.
2. Extract the folder and double-click the `Driver_Dashboard_Final.exe` file.
3. The server will automatically start and launch the analytics interface directly in your default web browser.

---

## 🧠 The Engineering Challenge

The biggest challenge in this project was memory management and multi-threading on mobile devices. Initially, processing heavy ML Kit facial algorithms while simultaneously saving HD video caused the Android UI thread to freeze and drop frames. 

To solve this, I completely bypassed the Flutter UI thread for video encoding. I engineered a background memory buffer that intercepts raw YUV camera bytes at 2 milliseconds per frame, storing them in a synchronized queue, which is then fed into a background FFmpeg engine upon triggering an "Accident Report". This resulted in a flawless, zero-lag user experience.

---
*Built with ❤️ for driver safety.*
