# Taco - A Collaborative TODO Application

**Taco** is a lightweight full-stack TODO application built with Flutter and Flask. It supports basic task management, local storage, and a simple PIN-based sharing feature that allows users to share task content without using an account system.

The project focuses on building a practical mobile application with a small backend service. The PIN sharing feature provides a straightforward way to transfer or reuse task information between users or devices.

## Key Features

* **Task Management**: Create, view, update, complete, and delete TODO items.
* **PIN-Based Sharing**: Generate a short PIN for a task and use it to retrieve shared task content.
* **Local and Remote Storage**: Store task data locally and use a backend database for shared PIN records.
* **Multi-Language Support**: Supports both English and Chinese through Flutter localization.
* **Full-Stack Implementation**: Uses Flutter for the mobile app and Flask for the backend API.

---

## Screenshots

<div align="center">
  <table style="table-layout: fixed; width: 100%; border-collapse: collapse;">
    <tr>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/1.png" height="320" /><br/>
        <sub style="font-size: 12px;"><b>Homepage</b></sub>
      </td>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/2.png" height="320" /><br/>
        <sub style="font-size: 12px;"><b>Add Task</b></sub>
      </td>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/3.png" height="320" /><br/>
        <sub style="font-size: 12px;"><b>Generate PIN</b></sub>
      </td>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/4.png" height="320" /><br/>
        <sub style="font-size: 12px;"><b>Enter PIN</b></sub>
      </td>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/5.png" height="320" /><br/>
        <sub style="font-size: 12px;"><b>Task Detail</b></sub>
      </td>
      <td align="center" valign="bottom" width="16%">
        <img src="assets/screenshots/6.png" height="320" /><br/>
        <sub style="font-size: 12px; white-space: nowrap;"><b>List Management</b></sub>
      </td>
    </tr>
  </table>
</div>

---

## Tech Stack

### Frontend

* **Framework**: Flutter
* **State Management**: Provider / setState
* **Internationalization**: flutter_localizations (en/zh)

### Backend

* **Language**: Python 3.x
* **Framework**: Flask
* **Database**: SQLite
* **API Style**: RESTful API

---

## How to Run

1. Start the backend server:

   ```bash
   python taco_share.py
   ```

2. Replace `YOUR BACKEND SERVER IP` with your actual backend IP address in:

   * `add_pin_page.dart`
   * `detail_page.dart`

3. Connect a device or emulator, then run the Flutter app:

   ```bash
   flutter run
   ```

---

## Project Structure

```text
Taco-Collaborative-TODO-APP/
├── lib/               # Flutter app code, including pages, widgets, and models
├── backend/           # Python backend service
│   ├── taco_share.py  # Backend API logic
│   └── taco.db        # SQLite database file
├── assets/            # Static assets, such as icons and screenshots
└── README.md          # Project documentation
```
