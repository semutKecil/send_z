# send_z

A cross-platform Flutter app for peer-to-peer file sharing using Nostr and WebRTC.

## Features

- Send and receive files directly between devices
- QR code scanning for quick pairing
- Nostr-based signaling for connection setup
- WebRTC for encrypted P2P transfer
- Progress tracking and file list management

## Tech Stack

- Flutter (Web, Android, iOS, Windows)
- WebRTC for peer-to-peer transfer
- Nostr for signaling
- Bloc pattern for state management
- auto_route for navigation

## Getting Started

```bash
dart pub get
dart run build_runner build -d
flutter run
```