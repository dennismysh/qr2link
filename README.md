# qr2link

Decode QR codes from screenshots into links — right in your browser. Flutter
web app that runs fully client-side, so nothing ever leaves your machine.

Live: https://dennismysh.github.io/qr2link/ (after first deploy)

## Features

- **Choose image**, **drag-and-drop**, or **paste** (Ctrl/Cmd+V) a screenshot.
- QR code is decoded locally with [`zxing2`](https://pub.dev/packages/zxing2) —
  no server, no upload.
- Decoded link shown with **Copy** and **Open** buttons.
- Mobile-ready Flutter project — Android and iOS can be enabled later with
  `flutter create --platforms=android,ios .`.

## Run locally

```sh
flutter pub get
flutter run -d chrome
```

## Tests

```sh
flutter analyze
flutter test
```

## Build for production

```sh
flutter build web --release --base-href /qr2link/
```

## Deploy

Pushing to `main` triggers `.github/workflows/deploy.yml`, which builds the web
app and publishes it to GitHub Pages. In repo **Settings → Pages**, set
**Source** to **GitHub Actions**.
