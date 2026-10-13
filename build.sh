#!/bin/bash
set -e

echo "=== 1. Checking Project ==="
ls -la

# If project is inside a subfolder or zip, handle it
if [ ! -d "GodDataX.xcodeproj" ] && [ -f "GodDataX_OB56_Project.zip" ]; then
    echo "Extracting zip..."
    unzip -o -q GodDataX_OB56_Project.zip || true
fi

if [ ! -d "GodDataX.xcodeproj" ] && [ -d "GodDataX IOS OB56/GodDataX.xcodeproj" ]; then
    echo "Copying from subfolder..."
    cp -r "GodDataX IOS OB56"/* .
fi

echo "=== 2. Building GodDataX with Xcode ==="
xcodebuild clean build \
  -project GodDataX.xcodeproj \
  -scheme GodDataX \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  AD_HOC_CODE_SIGNING_ALLOWED=YES \
  -derivedDataPath build

echo "=== 3. Packaging IPA ==="
mkdir -p Payload
APP_PATH=$(find build -name "GodDataX.app" -type d | head -n 1)
if [ -z "$APP_PATH" ]; then
    echo "ERROR: GodDataX.app not found in build directory!"
    find build
    exit 1
fi
echo "Found app at: $APP_PATH"
echo "=== Stripping debug symbols & strings ==="
strip -r -u "$APP_PATH/GodDataX" 2>/dev/null || true
cp -r "$APP_PATH" Payload/
zip -qr "GodDataX_v2_OB56.ipa" Payload
cp "GodDataX_v2_OB56.ipa" "GodDataX_OB56_v2.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_v3_OB56.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_v4_OB56.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_IOS_OB56.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build205.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build206.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build207.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build208.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build209.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build210.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build211.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build212.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build213.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build214.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build215.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build216.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build217.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_OB56_Build219.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_OB56_Build220.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_OB56_Build221.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_OB56_Build222.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_OB56_Build223.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build223_Animated.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build223_Smooth.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build222_AntiBan.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build222_Native.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_OB56_Secured_v7.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build221_Protected.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_OB56_TouchMatrix_v6.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build220_Red.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_v5_OB56.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_OB56_Matrix_Red.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_OB56_NewUpdate.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Build219_RedEdition.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_Home.ipa"
cp "GodDataX_v2_OB56.ipa" "GodDataX_com_goddatax_ios.ipa"
ls -lh GodDataX*.ipa
echo "=== Done! All GodDataX IPAs generated successfully ==="
