# Psiphon GUI for Linux

An unofficial, simple, and easy-to-use desktop GUI for Psiphon on Linux, built with Flutter. This application provides a user-friendly interface to control the `psiphon-tunnel-core` binary.

## Screenshot

![Application Screenshot](https://raw.githubusercontent.com/Mostbesep/psiphonForLinux/main/screenshots/screenshot.png)

## Features

- **One-Click Connect/Disconnect:** Easily start and stop the Psiphon tunnel.
- **Region Selection:** Change the server egress region before connecting.
- **Real-time Status:** View the current connection status (Connecting, Connected, Error, etc.).
- **Proxy Information:** Displays the local HTTP and SOCKS proxy ports when connected.
- **Automatic Setup:** On the first run, the application automatically downloads the required `psiphon-tunnel-core` binary for Linux and makes it executable.
- **Clean & Simple UI:** A minimal interface focused on getting you connected quickly.

## Getting Started

### Installation

The easiest way to get started is to download the latest pre-compiled binary from the **Releases** page.

1.  Go to the [Releases](https://github.com/Mostbesep/psiphonForLinux/releases) section.
2.  Download the latest executable file for Linux.
3.  Make the file executable:
    ```sh
    chmod +x psiphon_for_linux
    ```
4.  Run the application:
    ```sh
    ./psiphon_for_linux
    ```

### Building from Source

If you prefer to build the application yourself, make sure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install/linux) installed for Linux desktop development.

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/Mostbesep/psiphonForLinux.git
    cd psiphonForLinux
    ```
2.  **Get dependencies:**
    ```sh
    flutter pub get
    ```
3.  **Build the application:**
    ```sh
    flutter build linux --release
    ```
    The executable will be located in the `build/linux/x64/release/bundle/` directory.

## How It Works

This application acts as a wrapper around the official `psiphon-tunnel-core` binary.

- On its first launch, it downloads the binary from the official Psiphon repository.
- It manages the lifecycle of the Psiphon process (starting and stopping).
- It listens to the standard error stream of the process to parse JSON notices, updating the UI with real-time connection status and information.

## Disclaimer

This is an unofficial client. It is developed independently and is not affiliated with, endorsed, or sponsored by Psiphon Inc. The core tunneling technology is provided by the official Psiphon binary.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/Mostbesep/psiphonForLinux/blob/main/LICENSE) file for details.