<h1 align="center">Taco</h1>

<p align="center">
  <b>A lightweight collaborative TODO app built with Flutter and Flask.</b>
</p>

<p align="center">
  Create tasks, manage your workflow, and share TODO items with a simple PIN-based sharing system.
</p>

<p align="center">
  <a href="#why-taco">Why Taco</a> ·
  <a href="#features">Features</a> ·
  <a href="#screenshots">Screenshots</a> ·
  <a href="#tech-stack">Tech Stack</a> ·
  <a href="#getting-started">Getting Started</a>
</p>

---

## Why Taco

Most TODO apps are either too simple for sharing or too complex because they require accounts, cloud sync, and team workspaces.

Taco focuses on a smaller and cleaner workflow:

> Write a task locally. Generate a PIN. Share the task content. Retrieve it from another device.

It is designed as a practical full-stack mobile application that combines local task management with a lightweight backend sharing service.

Taco is suitable for:

- personal TODO management;
- quick task sharing between users;
- transferring task content between devices;
- demonstrating a Flutter + Flask full-stack mobile architecture;
- experimenting with account-free collaboration features.

---

## Features

| Feature | Description |
|---|---|
| Task management | Create, view, edit, complete, delete, and reorder TODO items |
| Local-first usage | Store and manage tasks locally on the device |
| PIN-based sharing | Generate a short PIN to share task content without user accounts |
| Task retrieval | Enter a PIN to retrieve shared task content from the backend |
| Multi-language support | Supports English and Chinese localization |
| Simple backend service | Uses Flask and SQLite to store shared PIN records |
| Mobile-first interface | Built with Flutter for a smooth Android app experience |

---

## Screenshots

<div align="center">
  <table style="table-layout: fixed; width: 100%; border-collapse: collapse;">
    <tr>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/1.png" height="320" /><br/>
        <sub><b>Homepage</b></sub>
      </td>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/2.png" height="320" /><br/>
        <sub><b>Add Task</b></sub>
      </td>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/3.png" height="320" /><br/>
        <sub><b>Generate PIN</b></sub>
      </td>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/4.png" height="320" /><br/>
        <sub><b>Enter PIN</b></sub>
      </td>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/5.png" height="320" /><br/>
        <sub><b>Task Detail</b></sub>
      </td>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/6.png" height="320" /><br/>
        <sub><b>List Management</b></sub>
      </td>
    </tr>
  </table>
</div>

---

## How It Works

Taco uses a simple local-first workflow.

```text
Create TODO item locally
        ↓
Generate sharing PIN
        ↓
Store shared task content in backend SQLite database
        ↓
Another user or device enters the PIN
        ↓
Shared task content is retrieved
```

This avoids the need for user accounts while still supporting basic task sharing.

---

## Tech Stack

### Frontend

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile app development |
| Dart | Application logic |
| Provider / setState | State management |
| flutter_localizations | English and Chinese localization |

### Backend

| Technology | Purpose |
|---|---|
| Python 3 | Backend language |
| Flask | REST API service |
| SQLite | Lightweight database for shared PIN records |

---

## Getting Started

### Prerequisites

Make sure you have the following installed:

- Flutter SDK
- Dart SDK
- Python 3
- Flask
- Android Studio or a connected Android device/emulator

---

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/Taco-Collaborative-TODO-APP.git
cd Taco-Collaborative-TODO-APP
```

---

### 2. Start the Backend Server

Go to the backend directory:

```bash
cd backend
```

Install Flask if needed:

```bash
pip install flask
```

Start the backend server:

```bash
python taco_share.py
```

The backend service will handle PIN generation and shared task retrieval.

---

### 3. Configure the Backend Address

Update the backend server address in the Flutter app.

Replace `YOUR BACKEND SERVER IP` with your actual backend IP address in:

```text
lib/add_pin_page.dart
lib/detail_page.dart
```

For local testing, make sure your phone or emulator can access the backend server.

---

### 4. Run the Flutter App

Return to the project root and run:

```bash
flutter pub get
flutter run
```

---

## Project Structure

```text
Taco-Collaborative-TODO-APP/
├── lib/                # Flutter app code
│   ├── pages/          # App pages and screens
│   ├── widgets/        # Reusable UI components
│   ├── models/         # Task data models
│   └── l10n/           # Localization files
├── backend/            # Flask backend service
│   ├── taco_share.py   # Backend API logic
│   └── taco.db         # SQLite database file
├── assets/             # Icons, images, and screenshots
└── README.md           # Project documentation
```

---

## License

This project is licensed under the Apache License 2.0.
