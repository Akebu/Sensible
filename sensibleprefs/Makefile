ARCHS = armv7 arm64

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SensiblePrefs
Sensible_CFLAGS = -fobjc-arc
Sensible_LDFLAGS += -Wl,-segalign,4000
SensiblePrefs_FILES = SensibleRootListController.m SensibleVibrationsController.m SensibleBehaviorController.m SensibleTranslationController.m
SensiblePrefs_INSTALL_PATH = /Library/PreferenceBundles
SensiblePrefs_FRAMEWORKS = UIKit MessageUI AudioToolbox
SensiblePrefs_PRIVATE_FRAMEWORKS = Preferences
SensiblePrefs_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/bundle.mk
internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SensiblePrefs.plist$(ECHO_END)
