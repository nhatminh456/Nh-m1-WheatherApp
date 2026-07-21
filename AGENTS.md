# AGENTS.md

This file provides guidance to AI coding agents (including Claude Code) when working with code in this repository.

## Project

`workapp` is a Flutter application (Dart SDK ^3.12.2). Currently only the Android platform is configured (`android/`); no iOS/web/desktop runners exist yet.

## Commands

- Install dependencies: `flutter pub get`
- Run the app: `flutter run`
- Static analysis (lint): `flutter analyze`
- Run all tests: `flutter test`
- Run a single test file: `flutter test test/widget_test.dart`
- Run a single test by name: `flutter test test/widget_test.dart --plain-name "Counter increments smoke test"`
- Build Android APK: `flutter build apk`

Linting uses `package:flutter_lints/flutter.yaml` (see `analysis_options.yaml`); no custom rule overrides are currently defined.

## Architecture

This project follows the layered MVVM architecture from the [Flutter app architecture guide](https://docs.flutter.dev/app-architecture/guide). New features should be added as self-contained modules under `lib/features/<feature_name>/`, split into up to three layers:

```
lib/features/<feature_name>/
├── presentation/
│   ├── views/            # Widget composition only (StatelessWidget/StatefulWidget)
│   └── viewmodels/        # ChangeNotifier-based state + commands for the view
├── domain/                 # Optional: only add when logic merges multiple
│   └── usecases/           # repositories, is complex, or is reused across ViewModels
└── data/
    ├── models/             # DTOs / on-the-wire shapes
    ├── repositories/       # Source of truth: caching, error handling, transforms
    └── services/           # Thin wrappers around one external data source each
```

Cross-feature code (shared models, repositories, services) belongs in `lib/shared/`, not duplicated per feature.

**Dependency direction is one-way**: View → ViewModel → (UseCase | Repository) → Service. Views must never call a Repository or Service directly, and ViewModels must never import Flutter widgets.

**Layer responsibilities:**

- **View**: renders `ViewModel` state; only conditional/animation/layout/simple-routing logic allowed — no business logic, no direct data access.
- **ViewModel**: one-to-one with its View; fetches from repositories/use-cases, transforms results into UI-ready state, exposes methods (commands) the View calls on user interaction. Extends `ChangeNotifier` (no external state-management package is installed yet — introduce one deliberately if a feature's needs outgrow `ChangeNotifier`/`ListenableBuilder`).
- **UseCase** (domain layer, optional): only add when a ViewModel needs to merge multiple repositories, or logic is complex/reused enough to not belong on the ViewModel directly. Don't add one for a simple pass-through to a single repository.
- **Repository**: single source of truth per model/domain concept; owns caching, retries, error handling, and mapping raw service data to domain models. Many-to-many with ViewModels and Services.
- **Service**: stateless wrapper around exactly one external data source (REST API, platform channel, local file, etc.); returns `Future`/`Stream` of raw data — no caching or business logic.

**Naming convention**: `snake_case` filenames, `PascalCase` classes, suffixed by role — e.g. `login_view.dart` → `LoginView`, `login_viewmodel.dart` → `LoginViewModel`, `user_repository.dart` → `UserRepository`, `auth_service.dart` → `AuthService`.

The `counter` feature (`lib/features/counter/`) is the reference example of this structure (presentation layer only — it has no data/domain needs). `lib/main.dart` should stay a thin app root (theme, initial route) and not contain feature UI or logic.
