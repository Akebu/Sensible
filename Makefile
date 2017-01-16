ARCHS = arm64 armv7

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Sensible
Sensible_FILES = Tweak.xm
Sensible_FRAMEWORKS = IOKit Foundation UIKit AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
