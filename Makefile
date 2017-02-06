ARCHS = arm64 armv7
TARGET = iphone:clang:latest:9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Sensible
Sensible_FILES = Tweak.xm SensibleController.xm SensibleEvents.xm SensibleConst.m
Sensible_LDFLAGS += -Wl,-segalign,4000
Sensible_FRAMEWORKS = IOKit Foundation UIKit AudioToolbox
Sensible_LIBRARIES = activator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall backboardd"
SUBPROJECTS += sensibleprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
