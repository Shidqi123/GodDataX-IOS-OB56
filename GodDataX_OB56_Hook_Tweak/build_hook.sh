#!/bin/bash
# Script Compile GodDataX Touch Hook Dylib for iOS
# Dapat dijalankan di macOS, GitHub Actions, atau Linux dengan clang iOS SDK

echo "=========================================="
echo "  COMPILING GODDATAX TOUCH HOOK (.DYLIB)  "
echo "=========================================="

TARGET_NAME="GodDataXTouchHook.dylib"
SOURCE_FILE="GodDataXTouchHook.mm"

# Gunakan clang iOS SDK jika tersedia
if command -v xcrun &> /dev/null; then
    SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
    xcrun -sdk iphoneos clang++ -shared -arch arm64 -isysroot "$SDK_PATH" \
        -miphoneos-version-min=14.0 \
        -fobjc-arc -framework Foundation -framework UIKit \
        "$SOURCE_FILE" -o "$TARGET_NAME"
    echo "✅ Berhasil dikompilasi: $TARGET_NAME"
else
    echo "⚠️ Xcode command line tools tidak terdeteksi di mesin lokal ini."
    echo "💡 Tweak ini juga dapat di-compile otomatis di GitHub Actions Mac runner!"
fi
