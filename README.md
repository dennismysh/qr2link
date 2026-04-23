# qr2link

Decode QR codes from screenshots into links — right in your browser. qr2link is
a Flutter web app that runs fully client-side: images are never uploaded, so
nothing ever leaves your machine.

Live site: https://dennismysh.github.io/qr2link/

## Features

- **Three ways to provide an image** — click to choose a file, drag-and-drop,
  or paste a screenshot from the clipboard with `Ctrl`/`Cmd`+`V`.
- **Local decoding** via [`zxing2`](https://pub.dev/packages/zxing2) and the
  [`image`](https://pub.dev/packages/image) package — no network calls.
- **Copy** or **Open** the decoded link with one click.
- **Material 3** UI with light and dark themes following the system preference.
- **Mobile-ready** Flutter project — Android and iOS can be enabled later with
  `flutter create --platforms=android,ios .`.

## Tech stack

- Flutter (Dart SDK `^3.5.4`)
- `zxing2` for QR decoding
- `image` for cross-format image decoding (PNG, JPEG, etc.)
- `file_picker`, `super_drag_and_drop`, `super_clipboard` for input
- `url_launcher` for opening decoded links

## Project layout

```
lib/
  main.dart               # app entry point
  app.dart                # MaterialApp + theming
  screens/home_screen.dart
  services/qr_decoder.dart  # zxing2 + image glue
  models/decoded_qr.dart
  widgets/
    drop_zone.dart        # drag / drop / paste / click-to-pick
    result_card.dart      # decoded link + copy / open actions
test/
  qr_decoder_test.dart
  fixtures/sample_qr.png
.github/workflows/deploy.yml  # build + publish to GitHub Pages
```

## Run locally

```sh
flutter pub get
flutter run -d chrome
```

## Tests and linting

```sh
flutter analyze
flutter test
```

## Build for production

```sh
flutter build web --release --base-href /qr2link/
```

The output is written to `build/web/`.

## Deploy

Pushing to `main` triggers `.github/workflows/deploy.yml`, which runs
`flutter analyze` and `flutter test`, builds the web app, and publishes it to
GitHub Pages. The workflow also copies `index.html` to `404.html` so the SPA
handles deep links.

In repo **Settings → Pages**, set **Source** to **GitHub Actions**.

## License

MIT — see [LICENSE](LICENSE).
