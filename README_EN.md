# README_EN.md

[日本語 (Japanese)](./README.md) | **English**

<div align="center">
  <h1>Kanary</h1>
  <p>A macOS utility for switching IME with left/right Command keys</p>
  <img src="docs/Kanary_screenshot.png" alt="Kanary Icon" width="700">
</div>

## Overview

**Kanary** lets you toggle between **Alphanumeric** and **Kana** input simply by tapping the left or right Command key. It’s lightweight, doesn’t interfere with standard shortcuts (e.g., Command + C/V), and only requires Accessibility permissions to run.

## Features

1. **Quick IME Switching via Command**  
   - Left Command → Alphanumeric  
   - Right Command → Kana  

2. **Simple, Lightweight Design**  
   - Enable/disable Kanary from the menubar icon  
   - Optionally exclude specific apps

3. **Compatible with macOS Functions**  
   - If you hold Command for ~0.3s or press other keys together, IME switching is canceled to preserve normal macOS shortcuts.  
   - *Note:* To accommodate certain macOS double-press features, there's a ~0.3s delay before IME switching takes effect (see [Future Plans](#今後の計画) for more details).

4. **Built-in Update Checker**  
   - Notifies you when a new version is available and can auto-download the latest release

## System Requirements

- **macOS**: 13.5 or later  
- **CPU**: Apple Silicon  
- **Required Permissions**: Go to System Settings → Privacy & Security → Accessibility to grant access to Kanary  
- **Keyboard Layout**: Officially supports US layout (other layouts may be unstable)

## Installation

1. Download the latest `Kanary.dmg` from [Releases](https://github.com/shntt/kanary/releases).  
2. Open the `.dmg` and move `Kanary.app` to your Applications folder.  
3. On first launch, follow the prompts to grant Accessibility permission.

### Uninstallation

1. Delete `Kanary.app` from your Applications folder.  
2. (Optional) Reset settings by removing:
   ```
   ~/Library/Preferences/com.shntt.kanary.plist
   ~/Library/Caches/com.shntt.kanary/
   ```

## Future Plans

- **Support for other layouts** (UK / JIS, etc.)  
- **Custom key assignments** (e.g., use Caps Lock or Option)  
- **More customization**: Adjust the IME toggle delay, enable sound/notifications, and more

Please share any ideas or requests via [Issues](https://github.com/shntt/kanary/issues).

## Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/shntt/kanary.git
   cd kanary
   ```
2. Open `Kanary.xcodeproj` with Xcode 15.0+  
3. Press **⌘+R** to build and run; Kanary appears in the menubar

## Contributing

- Report bugs or suggest features in [Issues](https://github.com/shntt/kanary/issues)  
- Submit code changes or new features via [Pull Requests](https://github.com/shntt/kanary/pulls)

1. Create a new branch (e.g., `feature/uk-layout-support`)  
2. Implement and test your changes  
3. Open a Pull Request

See [CONTRIBUTING.md](./CONTRIBUTING.md) for more details.

## License

Released under the [MIT License](./LICENSE.md).

## Acknowledgments

- Inspired by existing macOS IME switching utilities like **英かな**  
- Many thanks to the open-source community for their support