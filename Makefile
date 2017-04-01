ARCHS = arm64 armv7
TARGET = iphone:clang:latest:9.0
FINALPACKAGE=1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Sensible
Sensible_FILES = SensibleController.xm SensibleEvents.xm SensibleConst.m
#SensibleController.xm_CFLAGS = -fobjc-arc
Sensible_LDFLAGS += -Wl,-segalign,4000
Sensible_FRAMEWORKS = IOKit Foundation UIKit AudioToolbox  QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall backboardd"
SUBPROJECTS += sensibleprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
