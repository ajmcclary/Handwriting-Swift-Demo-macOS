#!/bin/bash

# Check for XcodeGen
if ! command -v xcodegen &> /dev/null; then
    echo "XcodeGen not installed. Installing..."
    brew install xcodegen
fi

# Create project.yml for XcodeGen
cat > project.yml << 'EOL'
name: HandwritingApp
options:
  bundleIdPrefix: com.example
  deploymentTarget:
    macOS: 13.0
  xcodeVersion: "15.0"
targets:
  HandwritingApp:
    type: application
    platform: macOS
    sources:
      - HandwritingApp
    settings:
      base:
        INFOPLIST_FILE: HandwritingApp/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.example.handwritingapp
        MACOSX_DEPLOYMENT_TARGET: 13.0
    info:
      path: HandwritingApp/Info.plist
      properties:
        CFBundleName: HandwritingApp
        CFBundleDisplayName: HandwritingApp
        CFBundlePackageType: APPL
        CFBundleShortVersionString: 1.0.0
        CFBundleVersion: 1
        LSMinimumSystemVersion: 13.0
        NSHighResolutionCapable: true
  HandwritingAppTests:
    type: bundle.unit-test
    platform: macOS
    sources:
      - HandwritingAppTests
    dependencies:
      - target: HandwritingApp
EOL

# Create Info.plist
mkdir -p HandwritingApp
cat > HandwritingApp/Info.plist << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOL

chmod +x setup_project.sh
