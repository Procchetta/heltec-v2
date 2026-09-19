#!/usr/bin/env bash
# ==============================================================================
# Script de compilación local de Meshtastic para Heltec V2.0 y V2.1
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Verificar si PlatformIO está instalado
if ! command -v pio &> /dev/null; then
    echo "❌ Error: PlatformIO CLI no está instalado."
    echo "💡 Instálalo con: pip install platformio"
    exit 1
fi

# Determinar tag
MESHTASTIC_TAG="$1"
if [ -z "$MESHTASTIC_TAG" ]; then
    echo "🔍 Consultando la última versión oficial de Meshtastic..."
    MESHTASTIC_TAG=$(curl -s https://api.github.com/repos/meshtastic/firmware/releases/latest | grep '"tag_name"' | cut -d '"' -f 4)
    if [ -z "$MESHTASTIC_TAG" ]; then
        MESHTASTIC_TAG="develop"
        echo "⚠️ No se pudo obtener el último tag, usando rama 'develop'."
    else
        echo "📌 Versión seleccionada: $MESHTASTIC_TAG"
    fi
else
    echo "📌 Versión especificada: $MESHTASTIC_TAG"
fi

BUILD_DIR="$ROOT_DIR/firmware_src"
OUTPUT_DIR="$ROOT_DIR/build_output"
mkdir -p "$OUTPUT_DIR"

# Clonar o actualizar repositorio de Meshtastic
if [ ! -d "$BUILD_DIR" ]; then
    echo "📥 Clonando meshtastic/firmware ($MESHTASTIC_TAG)..."
    git clone --depth 1 --branch "$MESHTASTIC_TAG" --recurse-submodules "$BUILD_DIR" https://github.com/meshtastic/firmware.git
else
    echo "🔄 Actualizando código fuente en $BUILD_DIR..."
    cd "$BUILD_DIR"
    git fetch --tags
    git checkout "$MESHTASTIC_TAG" || git checkout -b "$MESHTASTIC_TAG" "tags/$MESHTASTIC_TAG"
    git submodule update --init --recursive
    cd "$ROOT_DIR"
fi

# Copiar definiciones de variantes de respaldo
echo "🔧 Sincronizando variantes Heltec V2 y V2.1..."
mkdir -p "$BUILD_DIR/variants/esp32/heltec_v2"
mkdir -p "$BUILD_DIR/variants/esp32/heltec_v2.1"
cp -rf "$ROOT_DIR/variants/esp32/heltec_v2/"* "$BUILD_DIR/variants/esp32/heltec_v2/"
cp -rf "$ROOT_DIR/variants/esp32/heltec_v2.1/"* "$BUILD_DIR/variants/esp32/heltec_v2.1/"

# Compilar Heltec V2.0
echo ""
echo "🚀 ================= Compilando Heltec V2.0 ================="
cd "$BUILD_DIR"
pio run -e heltec-v2_0

# Compilar Heltec V2.1
echo ""
echo "🚀 ================= Compilando Heltec V2.1 ================="
pio run -e heltec-v2_1

# Copiar binarios generados a build_output
echo ""
echo "📦 Copiando binarios a $OUTPUT_DIR..."
cp -rf .pio/build/heltec-v2_0/*.bin "$OUTPUT_DIR/" 2>/dev/null || true
cp -rf .pio/build/heltec-v2_1/*.bin "$OUTPUT_DIR/" 2>/dev/null || true

echo "✅ Compilación completada con éxito. Archivos disponibles en $OUTPUT_DIR"
ls -la "$OUTPUT_DIR"
