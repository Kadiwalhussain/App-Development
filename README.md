# QR Code Pro - Scanner and Generator

A feature-rich Flutter application for scanning, generating, and managing QR codes with a beautiful modern UI.

## Features

### Core Features
- **📷 Scan QR Codes**: Use your device's camera to scan QR codes and barcodes instantly
- **🔲 Generate QR Codes**: Create custom QR codes from any text, URL, or data
- **📜 History**: Automatically saves all scanned and generated QR codes for easy access
- **🌙 Dark Mode**: Beautiful dark theme support with easy toggle

### Advanced Features
- **⚡ Quick Templates**: Pre-built templates for common QR code types:
  - URL/Website links
  - Email with subject and body
  - Phone numbers
  - SMS messages
  - WiFi network credentials
  - Contact cards (vCard)
  - Geographic locations
  - Calendar events

- **📋 Copy to Clipboard**: One-tap copy for scanned content
- **🔗 Smart URL Detection**: Automatically detects and offers to open URLs, emails, and phone numbers
- **📤 Share QR Codes**: Share generated QR codes as images
- **🎨 Beautiful UI**: Modern Material Design 3 interface with smooth animations

### Smart Content Detection
The app automatically detects and provides appropriate actions for:
- URLs (opens in browser)
- Email addresses (opens email client)
- Phone numbers (opens dialer)
- WiFi configurations
- Contact information (vCard)
- Geographic coordinates

## Screenshots

The app features multiple screens:
1. **Home Screen**: Feature cards for quick access to all functions
2. **Scan Screen**: Camera-based QR code scanner with result actions
3. **Generate Screen**: Create QR codes with share and copy options
4. **Templates Screen**: Quick QR code generation for common use cases
5. **History Screen**: View, search, and manage past QR codes

## Dependencies

- `flutter_barcode_scanner: ^2.0.0` - For scanning QR codes
- `qr_flutter: ^4.0.0` - For generating QR codes
- `share_plus: ^7.2.1` - For sharing QR codes as images
- `url_launcher: ^6.2.1` - For opening URLs, emails, and phone numbers
- `shared_preferences: ^2.2.2` - For storing history and settings
- `path_provider: ^2.1.1` - For temporary file storage when sharing

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
├── main.dart                    # Entry point and home screen
├── scan_qr_code.dart           # QR code scanning with copy/open actions
├── generate_qr_code.dart       # QR code generation with share feature
├── qr_templates.dart           # Quick templates for common QR types
├── history_screen.dart         # History management screen
└── services/
    ├── history_service.dart    # History persistence service
    └── theme_service.dart      # Dark/light theme management
```

## How to Use

### Scanning QR Codes
1. Launch the app
2. Tap "Scan" on the home screen
3. Point your camera at a QR code
4. The scanned data will be displayed with smart actions:
   - **Copy**: Copy content to clipboard
   - **Open**: Available for URLs, emails, and phone numbers

### Generating QR Codes
1. Launch the app
2. Tap "Generate" on the home screen
3. Enter your text or URL in the input field
4. Tap "Generate QR Code" button
5. Your QR code will be displayed with options to:
   - **Copy**: Copy the content
   - **Share**: Share the QR code as an image
   - **Clear**: Reset and generate a new code

### Using Quick Templates
1. Tap "Templates" on the home screen
2. Select a template type (URL, Email, Phone, WiFi, etc.)
3. Fill in the required fields
4. Tap "Generate QR Code"
5. The QR code is automatically saved to history

### Viewing History
1. Tap "History" on the home screen or app bar
2. Switch between tabs: All, Scanned, or Generated
3. Tap on any item to:
   - View the QR code
   - Copy content
   - Open URLs
   - Delete individual items
4. Use the trash icon to clear all history

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
