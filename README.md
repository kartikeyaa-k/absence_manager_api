# ️ Absence Manager API

A lightweight, testable API built with [`dart_frog`](https://pub.dev/packages/dart_frog) that serves enriched and paginated absence data. It reads from local JSON files and supports filtering by user, type, and date range.

## 🚀 Features

- 🧾 **Mocks data from JSON files** (absences + members)
- 🔄 **Pagination support** (`page`, `limit`)
- 🔍 **Filtering by**:
  - `userId`
  - `type` (e.g., vacation, sickness)
  - `startDate`, `endDate`
- 🧠 **Data enrichment**:
  - Joins absence entries with corresponding member name and image from members.json
- 🧪 **Testable**:
  - Includes tests for core routes
- 🧱 **Modular Dart Frog structure**:
  - Routes, Middleware, Repository, and Data


## 🗂 Project Structure

```bash
lib/
└── src/
    ├── data/
    │   └── absence_repository.dart
    ├── middleware/
    │   └── logger.dart
    └── routes/
        ├── absences/index.dart
        └── members/index.dart

data/
├── absences.json
└── members.json

test/
└── routes/
    ├── absences_test.dart
    └── members_test.dart
```


## ⚙️ Installation & Local Setup

### 1. Clone the repository

```bash
git clone https://github.com/kartikeyaa-k/absence_manager_api.git
cd absence_manager_api
```

### 2. Get dependencies

```bash
dart pub get
```

### 3. Run the API

```bash
dart_frog dev
```

By default, Dart Frog will start the server on:

```
http://localhost:8080
```

Ensure the following files exist in `data/` folder:
- `absences.json`
- `members.json`


## 🔌 Integration with Crewmeister App

In Crewmeister Flutter app, pass the local API base URL using `--dart-define`:

```bash
flutter run --dart-define=BASE_URL=http://localhost:8080
```


## 📦 Query Parameters

**Endpoint:** `/absences`

| Param      | Type   | Description                                |
|------------|--------|--------------------------------------------|
| `page`     | int    | Page number (required)                     |
| `limit`    | int    | Number of items per page (required)        |
| `userId`   | int    | Filter by specific user ID (optional)      |
| `type`     | string | Filter by absence type (optional)          |
| `startDate`| string | ISO string for date range filter (optional)|
| `endDate`  | string | ISO string for date range filter (optional)|


## ✅ Running Tests

```bash
dart test
```

---
