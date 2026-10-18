# Lock Screen (Tweak)

Automatically turns the screen off after a set idle time. Supports iOS 14 through 26 on jailbroken devices.

## Build
Requires Theos (https://theos.dev).

    make package              # rootful
    make package THEOS_PACKAGE_SCHEME=rootless   # rootless (Dopamine, etc.)
    make install              # over SSH to your device

## Settings
Edit `/var/mobile/Library/Preferences/com.yourname.lockscreen.plist`:
- `enabled` (Boolean)
- `idleSeconds` (Number, minimum 10)

Then post the notification `com.yourname.lockscreen/prefsChanged` or respring.

## Notes
- The screen-lock method is a private SpringBoard API. Its selector can change between iOS versions, so test on each target version.
- Bundle ID, author, and preferences path use placeholders: replace `com.yourname` everywhere.
