# 🚀 Cloudflare WARP Panel

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)](https://www.linux.org/)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=Cloudflare&logoColor=white)](https://www.cloudflare.com/)

**A modern graphical panel to manage the Cloudflare WARP client on Linux systems**

*Simple, elegant interface integrated with your desktop environment*

</div>

---

## ⚠️ Project Status

> **🧪 Beta Version:** This project is under active development. Bugs, errors, and incomplete features may occur. Your contributions and feedback are very welcome!

---

## ✨ Current Features

### ✅ **Implemented**

<table>
<tr>
<td>

### 🔌 **Connection Control**
- Connect/disconnect WARP with one click
- Real-time connection status display
- Visual status indicators (CONNECTED/DISCONNECTED)

</td>
<td>

### ⚙️ **Basic Settings**
- Mode switching (DoH/WARP)
- Session logout and re-authentication
- Debug access re-authentication

</td>
</tr>
<tr>
<td>

### 📋 **Registration Management**
- View current registration information
- Delete existing registration
- Register new WARP client

</td>
<td>

### ℹ️ **Information Panel**
- About Cloudflare window with version info
- Privacy policy and terms of service links
- Third-party licenses information

</td>
</tr>
</table>

### 🚧 **In Development**

<table>
<tr>
<td>

### 🌐 **DNS Settings**
- DNS fallback configuration
- DNS logging toggle
- DNS families management

</td>
<td>

### 🔗 **Proxy Configuration**
- Custom proxy port settings
- Proxy mode management

</td>
</tr>
<tr>
<td>

### 🎯 **Target Management**
- List available targets
- Target switching interface

</td>
<td>

### 🛡️ **Trusted Networks**
- Ethernet trust settings
- WiFi trust configuration
- SSID whitelist management

</td>
</tr>
<tr>
<td>

### 📊 **Statistics & Monitoring**
- Usage statistics display
- Connection analytics
- Performance metrics

</td>
<td>

### 🔧 **Debug Tools**
- Network debugging interface
- Posture checking tools
- Advanced diagnostics

</td>
</tr>
<tr>
<td>

### 🚇 **Tunnel Settings**
- Tunnel statistics
- Host and IP configuration
- Key rotation and protocol settings

</td>
<td>

### 🔌 **Advanced Features**
- Connector registration
- Compliance environment settings
- Virtual network (VNet) management

</td>
</tr>
</table>

---

## 📸 Screenshots

<div align="center">

### 🟢 Connected State
<img src="docs/inicial.png" alt="Connected initial screen" width="400px" style="border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">

### 🔴 Disconnected State
<img src="docs/inicial_1.png" alt="Disconnected initial screen" width="400px" style="border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">

### ⚙️ Settings Panel
<img src="docs/opçoes.png" alt="Settings screen" width="400px" style="border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">

</div>

---

## 🛠️ Technologies

<div align="center">

| Technology | Description | Version |
|:----------:|-------------|:------:|
| **Flutter** | Cross-platform framework for native interfaces | ![Flutter](https://img.shields.io/badge/3.x-blue) |
| **bitsdojo_window** | Advanced desktop window customization | ![Package](https://img.shields.io/badge/latest-green) |
| **flutter_svg** | SVG icons and logos rendering | ![Package](https://img.shields.io/badge/latest-green) |

</div>

---

## 🚀 Installation and Usage

### 📋 Prerequisites

Before starting, make sure you have:

- ✅ **Flutter SDK** installed and configured
- ✅ **Cloudflare WARP client** (`warp-cli`) installed on Linux system
- ✅ **Linux dependencies** for Flutter development

### 🔧 Development Mode

Run the project in development mode:

```bash
# Clone the repository
git clone https://github.com/johnpetersa19/cloudflare_warp_panel.git
cd cloudflare_warp_panel

# Install dependencies
flutter pub get

# Run in development mode
flutter run -d linux
```

### 📦 Production Build

To generate an optimized version for distribution:

```bash
# Generate release build
flutter build linux --release

# The executable will be available at:
# build/linux/x64/release/bundle/
```

### 🎯 Quick Installation

```bash
# Make the executable file executable
chmod +x build/linux/x64/release/bundle/cloudflare_warp_panel

# Run the application
./build/linux/x64/release/bundle/cloudflare_warp_panel
```

---

## 🏗️ Architecture

The application is built with a modular architecture:

- **Main Control Panel**: Central hub for connection management
- **Settings Dialogs**: Organized configuration windows
- **Command Executor**: Generic `warp-cli` command interface
- **Status Manager**: Real-time connection state monitoring

All functionality is based on the `_executeWarpCommand` function, which provides a standardized way to interact with the Cloudflare WARP CLI.

---

## 🤝 Contributing

<div align="center">

**We love contributions! Here's how you can help:**

</div>

### 🐛 Report Bugs
Found a problem? [Open an Issue](https://github.com/johnpetersa19/cloudflare_warp_panel/issues/new) describing:
- Expected vs actual behavior
- Steps to reproduce
- Screenshots if applicable
- System information

### 💡 Suggest Features
Have an amazing idea? [Create an Issue](https://github.com/johnpetersa19/cloudflare_warp_panel/issues/new) with:
- Detailed feature description
- Use cases
- Mockups or examples (optional)

### 🔧 Contribute Code

Priority areas for contribution:
- **DNS Settings Implementation**: Complete the DNS configuration interface
- **Statistics Dashboard**: Build the usage statistics display
- **Trusted Networks**: Implement network trust management
- **UI/UX Improvements**: Enhance the user interface design
- **Error Handling**: Improve error messages and validation

1. **Fork** this repository
2. **Create** a branch for your feature (`git checkout -b feature/awesome-feature`)
3. **Commit** your changes (`git commit -m 'Add awesome feature'`)
4. **Push** to the branch (`git push origin feature/awesome-feature`)
5. **Open** a Pull Request

---

## 📊 Development Roadmap

### 🎯 **Phase 1 - Core Features** (Current)
- [x] Basic connection control
- [x] Registration management
- [x] Settings foundation
- [x] DNS configuration interface
- [x] Proxy settings panel

### 🎯 **Phase 2 - Advanced Management**
- [x] Statistics and monitoring
- [x] Trusted networks configuration
- [x] Debug tools interface
- [x] Tunnel management

### 🎯 **Phase 3 - Professional Features**
- [x] Connector support
- [x] Environment compliance
- [x] VNet management
- [x] Advanced debugging

### 🎯 **Phase 4 - Enhancement**
- [ ] 🌐 Multi-language support
- [ ] 🔔 System notifications
- [ ] 🎨 Customizable themes
- [ ] 🚀 Auto-updater

---

## 📄 License

This project is licensed under the MIT License. See the [[LICENSE](https://github.com/johnpetersa19/cloudflare_warp_panel/blob/main/LICENSE.txt)] file for more details.

---

<div align="center">

**⭐ If this project was helpful to you, consider giving it a star!**

[![GitHub stars](https://img.shields.io/github/stars/johnpetersa19/cloudflare_warp_panel?style=social)](https://github.com/johnpetersa19/cloudflare_warp_panel/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/johnpetersa19/cloudflare_warp_panel?style=social)](https://github.com/johnpetersa19/cloudflare_warp_panel/network)

**Made with ❤️ for the Linux community**

</div>
