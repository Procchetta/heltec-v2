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

## 📥 Descargas y Tipos de Archivo

👉 Puedes descargar los binarios compilados más recientes en la pestaña de **[Releases](https://github.com/Procchetta/heltec-v2/releases)**.

| Placa | 🟢 Para Instalación Limpia (Desde Cero) | 🔄 Para Solo Actualizar (Conserva Configuración) |
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

> 💡 **Nota:** La placa V2.1 solucionó el conflicto de lectura de batería que ocurría en la V2.0 al activar el WiFi (ya que ADC2 comparte recursos con el módulo WiFi del ESP32).

---

## ⚡ Guía Detallada de Flasheo

### 🌐 Opción 1: ESP Web Flasher (Desde el Navegador)
*Recomendado en Chrome o Microsoft Edge vía cable USB.*

#### Caso A: 🟢 Instalación Limpia (Primera vez o restaurar de fábrica)
1. Conecta tu Heltec y entra a **[ESP Web Flasher (esp.huhn.me)](https://esp.huhn.me/)**.
2. Haz clic en **Connect** y selecciona el puerto serie de tu placa.
3. Coloca la dirección (offset): **`0x00`**.
4. Carga el archivo **`*-factory.bin`**.
5. *(Opcional)* Marca **Erase Flash** para borrar cualquier dato anterior.
6. Haz clic en **Program**.

#### Caso B: 🔄 Solo Actualizar (Conservar canales, claves y configuración de nodo)
1. Conecta tu Heltec y entra a **[ESP Web Flasher (esp.huhn.me)](https://esp.huhn.me/)**.
2. Haz clic en **Connect** y selecciona el puerto serie de tu placa.
3. Coloca la dirección (offset): **`0x10000`** *(¡Muy importante!)*.
4. Carga el archivo de actualización **`*.bin`** *(el que **NO** tiene la palabra factory)*.
5. ⚠️ **NO marques la opción de Borrar Flash (Erase Flash)**.
6. Haz clic en **Program**. Al reiniciar, tu nodo mantendrá todos sus canales y ajustes.

---

### 📱 Opción 2: Actualización Inalámbrica OTA (Desde la App de Meshtastic)
1. Descarga el archivo de actualización **`*.bin`** en tu teléfono o tablet.
2. Abre la App oficial de Meshtastic (Android/iOS) conectada por Bluetooth a tu placa.
3. Ve a **Settings** > **Radio Configuration** > **Firmware Update** (o menú de actualización OTA).
4. Selecciona el archivo `.bin` y confirma la actualización sin cables.

---

### 💻 Opción 3: Con `esptool.py` (Línea de Comandos)

#### Para Instalación Limpia (Borrado completo + Factory):
```bash
# 1. Borrar toda la flash
esptool.py --chip esp32 --port /dev/ttyUSB0 erase_flash

# 2. Escribir factory bin en 0x00
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash 0x00 firmware-heltec-v2_0-vX.X.X-factory.bin
```

#### Para Solo Actualizar (Mantener configuraciones):
```bash
# Escribir el binario de aplicación en el offset 0x10000 (sin borrar la flash)
esptool.py --chip esp32 --port /dev/ttyUSB0 --baud 921600 write_flash 0x10000 firmware-heltec-v2_0-vX.X.X.bin
```
*(En Windows reemplaza `/dev/ttyUSB0` por tu puerto `COMx`).*

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
