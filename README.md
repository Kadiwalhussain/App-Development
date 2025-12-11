# QR Code Scanner and Generator

A Flutter application that allows users to scan QR codes and generate custom QR codes.

## Features

- **Scan QR Codes**: Use your device's camera to scan QR codes and barcodes
- **Generate QR Codes**: Create custom QR codes from any text or URL
- **Clean UI**: Modern and intuitive user interface
- **Cross-Platform**: Works on Android and iOS

## Screenshots

The app has three main screens:
1. **Home Screen**: Choose between scanning or generating QR codes
2. **Scan Screen**: Scan QR codes using your camera
3. **Generate Screen**: Create custom QR codes from text

## Dependencies

- `flutter_barcode_scanner: ^2.0.0` - For scanning QR codes
- `qr_flutter: ^4.0.0` - For generating QR codes

## Setup Instructions

### Prerequisites
- Flutter SDK installed
- Android Studio or VS Code with Flutter extensions
- An Android device or emulator / iOS device or simulator

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Kadiwalhussain/App-Development.git
   cd App-Development
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   
   For Android:
   ```bash
   flutter run
   ```
   
   Or open the project in Android Studio and click the Run button.

### Running in Android Studio

1. Open Android Studio
2. Select "Open an Existing Project"
3. Navigate to the project folder and select it
4. Wait for Gradle sync to complete
5. Connect your Android device or start an emulator
6. Click the Run button (green play icon) or press Shift+F10

## Permissions

The app requires the following permissions:

### Android
- Camera access (for scanning QR codes)
- Already configured in `android/app/src/main/AndroidManifest.xml`

### iOS
- Camera access (for scanning QR codes)
- Already configured in `ios/Runner/Info.plist`

## Project Structure

```
lib/
├── main.dart              # Entry point and home screen
├── scan_qr_code.dart      # QR code scanning functionality
└── generate_qr_code.dart  # QR code generation functionality
```

## How to Use

### Scanning QR Codes
1. Launch the app
2. Tap "Scan QR Code" button
3. Point your camera at a QR code
4. The scanned data will be displayed on the screen

### Generating QR Codes
1. Launch the app
2. Tap "Generate QR Code" button
3. Enter your text or URL in the input field
4. Tap "Generate QR Code" button
5. Your QR code will be displayed
6. Tap "Clear" to reset and generate a new code

## Troubleshooting

### Common Issues

1. **Camera not working**
   - Make sure you've granted camera permissions
   - Check that your device has a working camera
   - Restart the app

2. **Build errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Rebuild the project

3. **Dependencies issues**
   - Run `flutter pub upgrade`
   - Check your Flutter SDK version

## Development

### Building for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is open source and available under the MIT License.

## Author

Kadiwalhussain

## Support

For issues and questions, please open an issue on the GitHub repository.
