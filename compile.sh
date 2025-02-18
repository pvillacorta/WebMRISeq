#!/bin/bash

cd frontend

# Configurar el proyecto
SRC_DIR="./src/seqEditor"
BUILD_DIR="./dist"

cmake -S "$SRC_DIR" -B "$BUILD_DIR" 

# Compilar el proyecto
cmake --build "$BUILD_DIR"

cd ..
