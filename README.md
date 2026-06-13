# KSLAS Admin UI

Flutter admin console for KSLAS academic operations across Android, iOS, web, desktop, and PWA.

## Current Scope

- Role-based workspace views for lecturers, invigilators, exam officers, DLC director, HoDs, level advisers, and all admins.
- Responsive shell for mobile, tablet, desktop, and web.
- Operational dashboard covering exams, approvals, people, alerts, invigilation, and result workflows.
- Mock repository layer ready to be replaced with real API services.

## Run

```sh
flutter pub get
flutter run -d chrome
flutter run -d windows
```

## Build Targets

```sh
flutter build web --pwa-strategy offline-first
flutter build apk
flutter build windows
```
