# 📡 Meshtastic Firmware Builder for Heltec V2 & V2.1

<p align="left">
  <strong>🌐 Language / Idioma:</strong> 
  <a href="README_EN.md">🇺🇸 <b>English</b></a> | 
  <a href="README.md">🇪🇸 Español</a>
</p>

[![Build Meshtastic Heltec V2 / V2.1](https://github.com/Procchetta/heltec-v2/actions/workflows/build-meshtastic.yml/badge.svg)](https://github.com/Procchetta/heltec-v2/actions/workflows/build-meshtastic.yml)
[![GitHub release](https://img.shields.io/github/v/release/Procchetta/heltec-v2?label=Latest%20Release)](https://github.com/Procchetta/heltec-v2/releases)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL_v3-blue.svg)](LICENSE)

Automated repository that weekly compiles the latest official release of **[Meshtastic Firmware](https://github.com/meshtastic/firmware)** for the legacy **Heltec WiFi LoRa 32 V2.0** and **Heltec WiFi LoRa 32 V2.1** boards.

---

## 🎯 Why this project?

In recent versions of Meshtastic, **Heltec V2.0 and V2.1** boards were marked as legacy hardware (`actively_supported = false`) and are no longer included in the standard release builds and default flashers.

This repository solves this by running an automated **GitHub Actions** workflow weekly that:
1. Checks whether Meshtastic has published a new stable or pre-release version.
2. Automatically builds the firmware using PlatformIO for **Heltec V2.0** (`heltec-v2_0`) and **Heltec V2.1** (`heltec-v2_1`).
3. Publishes a **GitHub Release** containing all ready-to-flash `.bin` and `.factory.bin` files.

---

## 📥 Downloads

👉 Download the latest compiled binaries directly from the **[Releases](https://github.com/Procchetta/heltec-v2/releases)** tab.

| Board | Recommended File (Clean Install) | Update File (OTA) |
| :--- | :--- | :--- |
| **Heltec V2.0** | `firmware-heltec-v2_0-*-factory.bin` | `firmware-heltec-v2_0-*.bin` |
| **Heltec V2.1** | `firmware-heltec-v2_1-*-factory.bin` | `firmware-heltec-v2_1-*.bin` |

---

## 🔍 Differences Between Heltec V2.0 and V2.1

It is crucial to flash the correct binary according to your hardware revision for accurate battery readings and GPIO behavior:

| Feature | Heltec V2.0 (`heltec-v2_0`) | Heltec V2.1 (`heltec-v2_1`) |
| :--- | :--- | :--- |
| **Battery Measurement Pin** | `GPIO 13` (ADC2) | `GPIO 37` (ADC1) |
| **ADC Channel** | `ADC2_GPIO13_CHANNEL` | `ADC1_GPIO37_CHANNEL` |
| **GPS / Ext Notify Enable** | Standard Pin | `PIN_GPS_EN = 37`, `EXT_NOTIFY_OUT = 13` |
| **Hardware Identifier** | `HELTEC_V2_0` (Model ID 5) | `HELTEC_V2_1` (Model ID 10) |

> 💡 **Note:** The V2.1 revision fixed the battery reading conflict present in V2.0 when WiFi is active (since ADC2 shares resources with the ESP32 WiFi module).

---

## ⚡ Flashing Guide

### Method 1: ESP Web Flasher (Browser-based) 🌐
*Recommended using Google Chrome or Microsoft Edge on Windows, Mac, or Linux.*

1. Connect your Heltec board to your computer with a data USB cable.
2. Navigate to **[ESP Web Flasher](https://esp.huhn.me/)** or the **[Meshtastic Web Flasher](https://flasher.meshtastic.org/)**.
3. Click **Connect** and select the serial port (e.g., `COM3` on Windows or `/dev/ttyUSB0` on Linux/Mac).
4. Load the **`*-factory.bin`** file at memory offset **`0x00`**.
5. Click **Program** and wait for the process to complete.

---

### Method 2: Using `esptool.py` (Command Line) 💻

If you prefer using the terminal:

```bash
# 1. Install esptool if not already installed
pip install --upgrade esptool

# 2. Erase the flash memory (recommended for clean installations)
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash

# 3. Flash the factory firmware at offset 0x00
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash 0x00 firmware-heltec-v2_0-vX.X.X-factory.bin
```
*(On Windows, replace `/dev/ttyUSB0` with your corresponding `COMx` port).*

---

## 🛠️ Local Compilation

If you wish to build the firmware on your local machine:

```bash
# 1. Clone this repository
git clone https://github.com/Procchetta/heltec-v2.git
cd heltec-v2

# 2. Grant execution permissions
chmod +x scripts/build_local.sh

# 3. Build the latest Meshtastic release
./scripts/build_local.sh

# Or specify a target version:
./scripts/build_local.sh v2.7.26.54e0d8d
```

Compiled binaries will be saved automatically in the `build_output/` folder.

---

## ⚙️ GitHub Actions Workflow Configuration

The workflow is defined in [`.github/workflows/build-meshtastic.yml`](.github/workflows/build-meshtastic.yml).

- **Automated Execution:** Every Sunday at `04:00 UTC`.
- **Manual Trigger:** In the **Actions** tab > **Build Meshtastic Heltec V2 / V2.1** > **Run workflow**, you can:
  - Specify a custom Meshtastic tag (or leave `latest`).
  - Toggle `force_build` to rebuild even if the release already exists.

### Required GitHub Permissions:
Ensure that under your repository settings (`Settings` > `Actions` > `General` > `Workflow permissions`) the following option is enabled:
- **Read and write permissions** (allows GitHub Actions to create Releases and upload binary assets).

---

## 📄 License

This project is licensed under the [GPL v3 License](https://www.gnu.org/licenses/gpl-3.0.html), adhering to the upstream Meshtastic project license.
