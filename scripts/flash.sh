#!/usr/bin/env bash
# ==============================================================================
# Script para flashear fácilmente Meshtastic en Heltec V2 y V2.1 con esptool
# ==============================================================================

set -e

PORT="${1:-/dev/ttyUSB0}"
BIN_FILE="$2"

if ! command -v esptool.py &> /dev/null; then
    echo "❌ esptool.py no está instalado."
    echo "💡 Instálalo con: pip install esptool"
    exit 1
fi

if [ -z "$BIN_FILE" ]; then
    echo "Uso: $0 <PUERTO_SERIAL> <ARCHIVO_FACTORY_BIN>"
    echo "Ejemplo: $0 /dev/ttyUSB0 build_output/firmware-heltec-v2_0-v2.7.26.54e0d8d-factory.bin"
    exit 1
fi

if [ ! -f "$BIN_FILE" ]; then
    echo "❌ Error: El archivo '$BIN_FILE' no existe."
    exit 1
fi

echo "⚠️  Asegúrate de que la placa Heltec esté conectada en $PORT"
echo "🧹 Borrando memoria flash..."
esptool.py --chip esp32 --port "$PORT" erase_flash

echo "⚡ Escribiendo firmware ($BIN_FILE)..."
esptool.py --chip esp32 --port "$PORT" --baud 921600 write_flash 0x00 "$BIN_FILE"

echo "✅ Flasheo completado con éxito. Reinicia el dispositivo para iniciar Meshtastic."
