# Vaudio - Vaxp Audio Player

A modern, professional Linux audio player built with Flutter, featuring a stunning **Glassmorphism** UI and robust Clean Architecture.

## Features

### 🎵 Advanced Audio Playback
- **Support for multiple formats**: MP3, FLAC, OGG, WAV, M4A, AAC.
- **Full Control**: Play, Pause, Next, Previous, Seek.
- **Speed Control**: Adjust playback speed from 0.5x to 2.0x.
- **Volume**: Integrated volume control with mute toggle.
- **Repeat & Shuffle**: Loop tracks/playlists and shuffle playback order.

### 📁 Built-in File Browser
- Navigate your local file system directly within the app.
- Filter to show only audio files.
- **One-click Play**: Instantly play any audio file.
- **Breadcrumb Navigation**: Easily track your location in the directory tree.

### 📋 Playlist Management
- Create, rename, and delete custom playlists.
- Add tracks from the file browser or queue.
- Reorder tracks within playlists.
- Persistent storage: Playlists are saved locally and load instantly.

### 🎨 Glassmorphism Design
- **Modern UI**: Translucent, blur-effect interfaces matching the Vaxp design language.
- **Themes**: Customizable appearance via settings.
- **Responsive**: Adapts gracefully to window resizing.

### ⌨️ Keyboard Shortcuts
- `Space`: Play / Pause
- `←` / `→`: Seek backward / forward (5s)
- `↑` / `↓`: Volume Up / Down
- `M`: Mute / Unmute
- `N`: Next Track
- `P`: Previous Track

## Architecture
- **Clean Architecture**: Separation of concerns (Domain, Data, Presentation layers).
- **State Management**: `flutter_bloc` for predictable and testable state handling.
- **Dependency Injection**: `get_it` for efficient service location.
- **Audio Engine**: Powered by `just_audio` and `media_kit` (via `libmpv`) for high-performance audio on Linux.

## Linux Build Requirements

To build **Vaudio** on Linux (Ubuntu/Debian), you need the following system dependencies installed:

```bash
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
sudo apt-get install -y libmpv-dev mpv
```

### Why `libmpv`?
Vaudio uses `media_kit` as its audio backend on Linux, which relies on the `libmpv` library for robust media playback.

## How to Build & Run

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/yourusername/vaudio.git
    cd vaudio
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run in Debug Mode**:
    ```bash
    flutter run -d linux
    ```

4.  **Build Release Version**:
    ```bash
    flutter build linux
    ```
    The executable will be located at `build/linux/x64/release/bundle/venom`.

## Project Structure

```
lib/
├── core/           # Shared utilities, themes, and base classes
├── features/       # Feature-based modules (Player, Browser, Playlist, Settings)
├── di/             # Dependency Injection setup
├── app.dart        # Main app widget and routing
└── main.dart       # Entry point
```

---
This project is part of the VAXP organization
