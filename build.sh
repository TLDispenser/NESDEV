#!/bin/bash

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <source_file.asm>"
    exit 1
fi

SRC_FILE="$1"
OUT_DIR="out"
BASENAME=$(basename "$SRC_FILE" .asm)
OBJ_FILE="$OUT_DIR/$BASENAME.o"
NES_FILE="$OUT_DIR/$BASENAME.nes"
CFG_FILE="nes.cfg"

mkdir -p "$OUT_DIR"


CA65_BIN="/usr/bin/ca65"
LD65_BIN="/usr/bin/ld65"

echo "[INFO] Checking for ca65 assembler..."
if [ ! -x "$CA65_BIN" ]; then
    echo "[ERROR] ca65 assembler not found at $CA65_BIN."
    exit 2
fi

echo "[INFO] Checking for ld65 linker..."
if [ ! -x "$LD65_BIN" ]; then
    echo "[ERROR] ld65 linker not found at $LD65_BIN."
    exit 2
fi

echo "[INFO] Assembling $SRC_FILE -> $OBJ_FILE"
"$CA65_BIN" "$SRC_FILE" -o "$OBJ_FILE"

if [ -f "$CFG_FILE" ]; then
    echo "[INFO] Linking $OBJ_FILE with config $CFG_FILE -> $NES_FILE"
    "$LD65_BIN" -o "$NES_FILE" -C "$CFG_FILE" "$OBJ_FILE"
else
    echo "[INFO] Linking $OBJ_FILE -> $NES_FILE"
    "$LD65_BIN" -o "$NES_FILE" "$OBJ_FILE"
fi

if [ -f "$NES_FILE" ]; then
    echo "[SUCCESS] Build successful: $NES_FILE"
else
    echo "[ERROR] Build failed: $NES_FILE not generated."
    exit 3
fi