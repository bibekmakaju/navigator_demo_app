# Navigation Router Demo

This Flutter app demonstrates the provided Riverpod + Navigator 2.0 router.

It includes examples for:

- Push a page and wait for a typed result.
- Push a page and ignore the result.
- Pop back with a result.
- Pop back without a result.
- Replace the current route.
- Replace the entire stack.
- Remove pages from the top of the stack.

## Run

```sh
cd navigation_router_demo
flutter pub get
flutter run -d chrome
```

This scaffold includes a simple web target. To add native platform folders later:

```sh
flutter create --platforms=android,ios,macos,web .
```

## Main Files

- `lib/app_router.dart` contains the custom router and route notifier.
- `lib/pages/login_view.dart` starts the app.
- `lib/pages/home_view.dart` demonstrates pushing pages and awaiting results.
- `lib/pages/product_view.dart` returns a product result or pops without one.
- `lib/pages/settings_view.dart` returns settings or demonstrates stack edits.
# navigator_demo_app
