# 📦 Absence Manager API

This is a lightweight backend service built using **Dart Frog**, designed to serve mock absence and member data.

## 🧱 Features

- REST API endpoints for absences and members  
- Supports pagination (`/absences?page=1&limit=10`)  
- Supports filtering by `userId` (`/absences?userId=<id>`)  
- Returns enriched absence records with `memberName` and `memberImage`  
- Serves mock JSON data from static files  
- Docker-ready for cloud deployment (Render)  
- Logging middleware for all incoming requests 

---

## 📁 Folder Structure

```
absence_manager_api/
├── data/
│   ├── absences.json          # Mock data for absences
│   └── members.json           # Mock data for members
├── lib/
│   └── src/
│       └── data/
│           └── absence_repository.dart  # Loads, paginates, and enriches data
├── middleware/
│   └── logger.dart            # Logs method, path, status code, response time
├── routes/
│   ├── absences/
│   │   └── index.dart         # GET /absences with pagination, filtering, enrichment
│   └── members/
│       └── index.dart         # GET /members
├── test/
│   └── routes/                # Tests for each route
│       ├── absences_test.dart
│       └── members_test.dart
├── Dockerfile                 # Deployment setup
├── dart_frog.yaml             # Middleware configuration
├── analysis_options.yaml      # Linting and code quality rules
├── pubspec.yaml               # Dart dependencies (package: absence_manager_api)
└── README.md                  # You are here
```

---

## 🛠 dart_frog.yaml

```
middleware:
  - ./middleware/logger.dart
```

---

## 🚀 How to Run Locally

### 1. Install Dart Frog CLI (once)
```bash
dart pub global activate dart_frog_cli
```

### 2. Add CLI to your shell (if needed)
```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### 3. Start the server
```bash
dart_frog dev
```

### 4. Access the endpoints
- [http://localhost:8080/absences](http://localhost:8080/absences)
- [http://localhost:8080/members](http://localhost:8080/members)

Supports query params like:
```
/absences?page=2&limit=5
/absences?userId=2664
```

---

## 🌐 Live API Deployment (Render) 
**TODO**: Replace with actual Render URL once deployed.

**Base URL**: `https://absence-manager-api.onrender.com`

### Available Endpoints:

- `GET /absences`
  - Optional query params:
    - `page` (default: 1)
    - `limit` (default: 10)

- `GET /members`
  - Returns all members

---

## 🧪 Testing

To run all tests:
```bash
dart test
```

To analyze code and enforce best practices:
```bash
dart analyze
```

---

## 📏 Linting (analysis_options.yaml)

We use `very_good_analysis` for consistent, production-grade code quality.

```yaml
include: package:very_good_analysis/analysis_options.5.1.0.yaml
```

Rules customized for:
- Return types
- Avoiding print
- Clean parameter usage
- Final + const where applicable

---
