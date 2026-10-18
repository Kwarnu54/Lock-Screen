TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockScreen
LockScreen_FILES = Tweak.x
LockScreen_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS)/makefiles/tweak.mk

# For rootless jailbreaks (Dopamine, etc.), build with:
#   make package THEOS_PACKAGE_SCHEME=rootless
