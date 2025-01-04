#!/bin/bash

# Create Xcode project
xcodegen generate || {
    echo "XcodeGen not installed. Installing..."
    brew install xcodegen
    xcodegen generate
}

# Copy ML model
mkdir -p HandwritingApp/Resources
cp -r TrOCR-Handwritten.mlpackage HandwritingApp/Resources/

# Create project.yml for XcodeGen
cat > project.yml << 'EOL'
name: HandwritingApp
options:
  bundleIdPrefix: com.example
  deploymentTarget:
    iOS: 16.0
targets:
  HandwritingApp:
    type: application
    platform: iOS
    sources:
      - HandwritingApp
    settings:
      base:
        INFOPLIST_FILE: HandwritingApp/Info.plist
        PRODUCT_BUNDLE_IDENTIFIER: com.example.handwritingapp
    info:
      path: HandwritingApp/Info.plist
      properties:
        CFBundleName: HandwritingApp
        CFBundleDisplayName: HandwritingApp
        CFBundlePackageType: APPL
        CFBundleShortVersionString: 1.0.0
        CFBundleVersion: 1
        UILaunchStoryboardName: ""
        UIApplicationSceneManifest:
          UIApplicationSupportsMultipleScenes: false
          UISceneConfigurations:
            UIWindowSceneSessionRoleApplication:
              - UISceneConfigurationName: Default Configuration
                UISceneDelegateClassName: $(PRODUCT_MODULE_NAME).SceneDelegate
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
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
        <key>UISceneConfigurations</key>
        <dict>
            <key>UIWindowSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneConfigurationName</key>
                    <string>Default Configuration</string>
                    <key>UISceneDelegateClassName</key>
                    <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                </dict>
            </array>
        </dict>
    </dict>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
EOL

chmod +x setup_project.sh
