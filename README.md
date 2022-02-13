# Andax

Application for secondary language learning. Utilizes crowdsroucing for content creation and management. Fascilitates langugage acquisition through interactive stories.

Built with Flutter & Firebase & Algolia.
Web version is available at https://andaxapp.web.app/.

## Getting Started

### Development

```sh
> git clone https://github.com/raxysstudios/andax.git
> cd andax
> pub get
```

And in two separate terminals, run the following commands:
```sh
> flutter pub run build_runner watch
# and
> flutter run -d chrome --web-port 80
```

_Note: Port 80 is required for the web version for authentication to work._

### Building for release

First run the following command to generate the missing code:
```sh
> flutter pub run build_runner build
```

and then:

#### Android

```
> flutter build apk
```

#### iOS

```
> flutter build ipa
```
And then open the generated `build/ios/archive/App.xcarchive` in Xcode and click on "**Distribute App**".

#### Web

```
> flutter build web
```
And deploy the generated `build/web/` folder to your web server.


## Project Structure

### Folder organization

The application's [lib](./lib) directory structure is inspired by the [Feature-Sliced Design](https://feature-sliced.design/en/docs/concepts/app-splitting) and is organized into the following folders:

```
lib/
├── config/
|   # Contains configuration files for the application
│   └── themes/
├── routes/
|   # Similar to the Application/Pages level from FSD
│   # TODO: add actual structure
├── core/
|   # "Entities" in FSD: Slices of business entities for implementing a more complex Business Logic
├── modules/
|   # Similar to the "features" slice from FSD
│   ├── [feature name]/
│   │   ├── screens/
|   |   |   # The main Scaffold widgets that compose ./widgets/
│   │   ├── services/
|   |   |   # Wrappers around Algolia/Firebase queries
│   │   ├── utils/
|   |   |   # Helper functions that are difficult to group under another category. Better use scarcely.
│   │   ├── models/
|   |   |   # Simple serializable data structures
│   │   └── widgets/
├── shared
|   # Contains shared code that is used across multiple modules
│   ├── widgets/
│   ├── services/
│   └── utils/
└── main.dart # The entry point of the application
```

The modularity aims to reduce coupling in the codebase and makes it easier to isolate changes to specific features.

**References**:
- https://feature-sliced.design/en/docs/concepts/app-splitting
- https://medium.com/flutter-community/scalable-folder-structure-for-flutter-applications-183746bdc320
- https://medium.com/flutter-community/flutter-scalable-folder-files-structure-8f860faafebd

### Style recommendations

- Use strict Dart Analyzer rules
- Add documentation comments (`///`) wherever possible
- Use `snake_case` for files/folders
- Use `package:` imports among layers. Relative imports are allowed inside the module (or when there is a maximum of one `../`).
