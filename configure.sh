#!/bin/bash

# Configurar variables de entorno
export QT=/home/pablov/Qt/6.6.2
export EMSDK=/home/pablov/emsdk

cd client

# NPM
npm install
npm run build

# Directorios
SRC_DIR="./src/seqEditor"
BUILD_DIR="./dist"
QT_TOOLCHAIN_FILE="$QT/wasm_singlethread/lib/cmake/Qt6/qt.toolchain.cmake"
QT_CHAINLOAD_TOOLCHAIN_FILE="$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake"

# Verificar la existencia de los archivos importantes
if [ ! -f "$QT_CHAINLOAD_TOOLCHAIN_FILE" ]; then
    echo "Error: No se encontró $QT_CHAINLOAD_TOOLCHAIN_FILE"
    exit 1
fi

if [ ! -f "$QT_TOOLCHAIN_FILE" ]; then
    echo "Error: No se encontró $QT_TOOLCHAIN_FILE"
    exit 1
fi

# Crear el directorio de compilación si no existe
mkdir -p "$BUILD_DIR"

# Configurar el proyecto con CMake
cmake -S "$SRC_DIR" \
      -B "$BUILD_DIR" \
      -DCMAKE_GENERATOR=Ninja \
      -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_PREFIX_PATH="$QT/wasm_singlethread" \
      -DCMAKE_C_COMPILER="$EMSDK/upstream/emscripten/emcc" \
      -DCMAKE_CXX_COMPILER="$EMSDK/upstream/emscripten/em++" \
      -DCMAKE_TOOLCHAIN_FILE="$QT_TOOLCHAIN_FILE" \
      -DQT_CHAINLOAD_TOOLCHAIN_FILE="$QT_CHAINLOAD_TOOLCHAIN_FILE"

cd ..
