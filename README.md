# Mobile Programming (SE202)

Coursework and laboratory assignments for Mobile Programming with Flutter and Dart.

- Student: Jaxongir Niyazmetov
- ID: 240451

## Repository Structure

```
MobileProgramming/
└── Lab 5/
    ├── pubspec.yaml
    └── lib/
        ├── main.dart
        ├── task_host.dart
        ├── task1_screen.dart
        ├── task2_screen.dart
        ├── task3_screen.dart
        ├── task4_screen.dart
        ├── task5_screen.dart
        └── task6_screen.dart
```

## Lab 5: Navigation and Routing

All 6 categories of the workbook, 5 tasks each (30 tasks). Each category file holds its 5 tasks, opened from a menu. The small button at the bottom left of a running task goes back to the menu. `task_host.dart` holds that shared menu and button.

- **Task 1: Navigator push and pop** (`task1_screen.dart`)
  - Two screens, three screen chain, pushReplacement login, popUntil back to the start, canPop back button.
- **Task 2: Named routes** (`task2_screen.dart`)
  - Route table with constants, menu with four routes, onUnknownRoute 404 page, drawer with pushReplacementNamed, log out with pushNamedAndRemoveUntil.
- **Task 3: Constructor arguments** (`task3_screen.dart`)
  - Product list to details, greeting, contact card, colour picker returning a result, counter editor handling a null result.
- **Task 4: Named route arguments** (`task4_screen.dart`)
  - ScreenArguments class, number and its square, user profile, onGenerateRoute with type check, rating result from a named route.
- **Task 5: Transition animations** (`task5_screen.dart`)
  - Fade, slide from the right, slide from the bottom, scale with fade, reusable FadeRoute and a global page transitions theme.
- **Task 6: go_router** (`task6_screen.dart`)
  - go vs push, path parameters, extra object, named routes with errorBuilder, CustomTransitionPage with a reusable buildPage helper.

## Running the Project

Copy the `lib` folder into a Flutter project, add the `go_router` package, then run it:

```bash
flutter pub add go_router
flutter run
```
