#!/bin/bash
# Mobile Development Setup
# Installs Flutter, (on macOS) Xcode + CocoaPods for iOS, and Android Studio +
# SDK + a Pixel 9 emulator for Android.

set -e

echo "Setting up mobile development environment..."

if [[ ! -x "$(command -v brew)" ]]; then
    echo "Error: Homebrew not installed."
    exit 1
fi

if [[ "$(uname -s)" == "Darwin" ]]; then
    # Xcode Command Line Tools — required by brew, git, and friends.
    if ! xcode-select -p >/dev/null 2>&1; then
        echo "Installing Xcode Command Line Tools (a GUI prompt will appear)..."
        xcode-select --install || true
        echo "Re-run this script once Command Line Tools finish installing."
        exit 1
    fi

    # Full Xcode.app — required for Flutter iOS builds. Apple ID gated and
    # ~10 GB; install manually from the Mac App Store, then re-run this script.
    if [[ ! -d "/Applications/Xcode.app" ]]; then
        cat <<EOF

Xcode.app is not installed. Install it from the Mac App Store:
    https://apps.apple.com/app/xcode/id497799835
Then re-run this script.
EOF
        exit 1
    fi

    # Point xcode-select at the full Xcode if still on CommandLineTools.
    if [[ "$(xcode-select -p)" != *"Xcode.app"* ]]; then
        echo "Switching xcode-select to /Applications/Xcode.app..."
        sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
    fi

    # Xcode license + first-launch components (simulators, plugins) require
    # sudo. Verify they've been completed via the Xcode GUI.
    if ! xcodebuild -version >/dev/null 2>&1 || ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
        cat <<EOF

Xcode needs its first-launch setup. Open /Applications/Xcode.app once, accept
the license, and let it install required components. Then re-run this script.
EOF
        exit 1
    fi

    # CocoaPods — required for Flutter iOS plugin builds.
    if ! command -v pod >/dev/null 2>&1; then
        echo "Installing CocoaPods..."
        brew install cocoapods
    fi

    # Android Studio — IDE for Android development.
    if [[ ! -d "/Applications/Android Studio.app" ]]; then
        echo "Installing Android Studio..."
        brew install --cask android-studio
    fi

    # Standalone command-line tools — gives us sdkmanager/avdmanager without
    # needing to run the Android Studio setup wizard.
    if [[ ! -d /opt/homebrew/share/android-commandlinetools/cmdline-tools/latest ]]; then
        echo "Installing Android command-line tools..."
        brew install --cask android-commandlinetools
    fi

    # Use the conventional SDK location so Android Studio finds it. The brew
    # cask anchors at /opt/homebrew/share/android-commandlinetools and
    # avdmanager resolves its SDK root from the cmdline-tools location (not
    # $ANDROID_HOME), so we mirror cmdline-tools into the SDK home and invoke
    # the tools from there.
    export ANDROID_HOME="${ANDROID_HOME:-${HOME}/Library/Android/sdk}"
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    if [[ ! -d "$ANDROID_HOME/cmdline-tools/latest" ]]; then
        cp -R /opt/homebrew/share/android-commandlinetools/cmdline-tools/latest \
            "$ANDROID_HOME/cmdline-tools/latest"
    fi
    sdkmanager_bin="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
    avdmanager_bin="$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager"

    android_platform="android-36"
    android_system_image="system-images;${android_platform};google_apis;arm64-v8a"
    android_avd_name="Pixel_9_API_36"

    echo "Accepting Android SDK licenses..."
    yes | "$sdkmanager_bin" --licenses >/dev/null
    echo "Installing Android SDK packages..."
    "$sdkmanager_bin" \
        "platform-tools" \
        "emulator" \
        "platforms;${android_platform}" \
        "build-tools;36.0.0" \
        "${android_system_image}" >/dev/null

    # Create a Pixel 9 AVD if one doesn't exist yet.
    if ! "$avdmanager_bin" list avd 2>/dev/null \
            | grep -q "Name: ${android_avd_name}\b"; then
        echo "Creating ${android_avd_name} emulator..."
        echo "no" | "$avdmanager_bin" create avd \
            --name "${android_avd_name}" \
            --device "pixel_9" \
            --package "${android_system_image}"
    fi
fi

# Flutter
if ! command -v flutter >/dev/null 2>&1; then
    echo "Installing Flutter..."
    brew install --cask flutter
fi

if [[ -x "$(command -v flutter)" ]]; then
    if [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
        flutter config --android-sdk "$ANDROID_HOME" >/dev/null
        echo "Accepting Flutter Android licenses..."
        yes | flutter doctor --android-licenses >/dev/null 2>&1 || true
    fi
    echo ""
    echo "Running flutter doctor..."
    flutter doctor
fi

echo "Mobile development environment setup complete!"
