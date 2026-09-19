# 📡 Meshtastic Firmware Builder para Heltec V2 y V2.1

<p align="left">
  <strong>🌐 Idioma / Language:</strong> 
  <a href="README.md">🇪🇸 <b>Español</b></a> | 
  <a href="README_EN.md">🇺🇸 English</a>
</p>

[![Build Meshtastic Heltec V2 / V2.1](https://github.com/Procchetta/heltec-v2/actions/workflows/build-meshtastic.yml/badge.svg)](https://github.com/Procchetta/heltec-v2/actions/workflows/build-meshtastic.yml)
[![GitHub release](https://img.shields.io/github/v/release/Procchetta/heltec-v2?label=Última%20Versión)](https://github.com/Procchetta/heltec-v2/releases)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL_v3-blue.svg)](LICENSE)

Repositorio automatizado que compila semanalmente la última versión oficial de **[Meshtastic Firmware](https://github.com/meshtastic/firmware)** para las placas clásicas **Heltec WiFi LoRa 32 V2.0** y **Heltec WiFi LoRa 32 V2.1**.

---

## 🎯 ¿Por qué este proyecto?

En las versiones recientes de Meshtastic, las placas **Heltec V2.0 y V2.1** fueron marcadas como hardware heredado (`actively_supported = false`) y no se incluyen en los instaladores predeterminados.

Este repositorio resuelve ese problema ejecutando un flujo de **GitHub Actions** semanalmente que:
1. Comprueba si Meshtastic ha publicado una nueva versión estable o pre-release.
2. Compila automáticamente el firmware con PlatformIO para **Heltec V2.0** (`heltec-v2_0`) y **Heltec V2.1** (`heltec-v2_1`).
3. Genera y publica un **Release en GitHub** con los archivos `.bin` y `.factory.bin` listos para flashear.

---

## 📥 Descargas

👉 Puedes descargar los binarios compilados más recientes directamente en la pestaña de **[Releases](https://github.com/Procchetta/heltec-v2/releases)**.

| Placa | Archivo Recomendado (Instalación limpia) | Archivo para Actualización (OTA) |
| :--- | :--- | :--- |
| **Heltec V2.0** | `firmware-heltec-v2_0-*-factory.bin` | `firmware-heltec-v2_0-*.bin` |
| **Heltec V2.1** | `firmware-heltec-v2_1-*-factory.bin` | `firmware-heltec-v2_1-*.bin` |

---

## 🔍 Diferencias entre Heltec V2.0 y V2.1

Es crucial flashear la versión correcta según tu hardware para que la lectura de batería y pines GPIO funcionen adecuadamente:

| Característica | Heltec V2.0 (`heltec-v2_0`) | Heltec V2.1 (`heltec-v2_1`) |
| :--- | :--- | :--- |
| **Pin de Medición de Batería** | `GPIO 13` (ADC2) | `GPIO 37` (ADC1) |
| **Canal ADC** | `ADC2_GPIO13_CHANNEL` | `ADC1_GPIO37_CHANNEL` |
| **Habilitación de GPS / Ext Notify** | Pin estándar | `PIN_GPS_EN = 37`, `EXT_NOTIFY_OUT = 13` |
| **Identificador de Hardware** | `HELTEC_V2_0` (Model ID 5) | `HELTEC_V2_1` (Model ID 10) |

> 💡 **Nota:** La placa V2.1 solucionó el conflicto de lectura de batería que ocurría en la V2.0 al activar el WiFi (ya que ADC2 comparte recursos con el módulo WiFi).

---

## ⚡ Guía de Flasheo

### Método 1: ESP Web Flasher (Directamente desde el navegador) 🌐
*Recomendado para Chrome o Microsoft Edge en Windows, Mac o Linux.*

1. Conecta tu placa Heltec a la computadora mediante un cable USB de datos.
2. Ingresa a **[ESP Web Flasher](https://esp.huhn.me/)** o al **[Meshtastic Web Flasher](https://flasher.meshtastic.org/)**.
3. Haz clic en **Connect** y selecciona el puerto serie correspondiente (ej. `COM3` en Windows o `/dev/ttyUSB0` en Linux/Mac).
4. Carga el archivo **`*-factory.bin`** en la dirección de memoria **`0x00`**.
5. Haz clic en **Program** y espera a que termine el proceso.

---

### Método 2: Con `esptool.py` (Línea de comandos) 💻

Si prefieres usar la terminal:

```bash
# 1. Instalar esptool si no lo tienes
pip install --upgrade esptool

# 2. Borrar la memoria flash (recomendado en primera instalación)
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash

# 3. Flashear el firmware factory en offset 0x00
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash 0x00 firmware-heltec-v2_0-vX.X.X-factory.bin
```
*(En Windows, reemplaza `/dev/ttyUSB0` por tu puerto `COMx`).*

---

## 🛠️ Compilación Local

Si deseas compilar el firmware en tu propia máquina:

```bash
# 1. Clonar este repositorio
git clone https://github.com/Procchetta/heltec-v2.git
cd heltec-v2

# 2. Dar permisos de ejecución al script
chmod +x scripts/build_local.sh

# 3. Compilar la última versión disponible de Meshtastic
./scripts/build_local.sh

# O especificar una versión en particular:
./scripts/build_local.sh v2.7.26.54e0d8d
```

Los binarios generados se guardarán automáticamente en la carpeta `build_output/`.

---

## ⚙️ Configuración del Flujo de GitHub Actions

El flujo de trabajo se encuentra en [`.github/workflows/build-meshtastic.yml`](.github/workflows/build-meshtastic.yml).

- **Ejecución automática:** Cada domingo a las `04:00 UTC`.
- **Ejecución manual:** En la pestaña **Actions** > **Build Meshtastic Heltec V2 / V2.1** > **Run workflow**, puedes:
  - Seleccionar un tag específico de Meshtastic (o dejar `latest`).
  - Activar `force_build` para forzar la compilación aunque el release ya exista.

### Permisos requeridos en GitHub:
Asegúrate de que en la configuración de tu repositorio (`Settings` > `Actions` > `General` > `Workflow permissions`) esté seleccionada la opción:
- **Read and write permissions** (para permitir que GitHub Actions cree los Releases y suba los binarios).

---

## 📄 Licencia

Este proyecto está bajo la licencia [GPL v3](https://www.gnu.org/licenses/gpl-3.0.html), en concordancia con la licencia del proyecto oficial de Meshtastic.
