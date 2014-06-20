TOP := .
TOPDIR :=

BUILD_SYSTEM := $(TOPDIR)build/core
BUILD_MAKEFILE := Modules.mk

# This is the default target.  It must be the first declared target.
DEFAULT_GOAL := goal
.PHONY: $(DEFAULT_GOAL)
$(DEFAULT_GOAL):

DEFAULT_CLEAN := clean

# Used to force goals to build.  Only use for conditionally defined goals.
.PHONY: FORCE
FORCE:

# These goals don't need to collect and include Android.mks/CleanSpec.mks
# in the source tree.
dont_bother_goals := clean clobber dataclean installclean \
    help out \
    snod systemimage-nodeps \
    stnod systemtarball-nodeps \
    userdataimage-nodeps userdatatarball-nodeps \
    cacheimage-nodeps \
    vendorimage-nodeps \
    ramdisk-nodeps \
    bootimage-nodeps

ifneq ($(filter $(dont_bother_goals), $(MAKECMDGOALS)),)
dont_bother := true
endif

# Set up various standard variables based on configuration
# and host information.
include $(BUILD_SYSTEM)/config.mk

# Bring in standard build system definitions.
include $(BUILD_SYSTEM)/definitions.mk



ifneq ($(ONE_SHOT_MAKEFILE),)
# We've probably been invoked by the "mm" shell function
# with a subdirectory's makefile.
include $(ONE_SHOT_MAKEFILE)

else # ONE_SHOT_MAKEFILE

#
# Include all of the makefiles in the system
#

# Can't use first-makefiles-under here because
# --mindepth=2 makes the prunes not work.
ifdef FIND_MAKEFILE_PY
subdir_makefiles := \
	$(shell build/tools/findleaves.py --prune=$(OUT_DIR) --prune=.repo --prune=.git $(subdirs) $(BUILD_MAKEFILE))
else # FIND_MAKEFILE_PY
#subdir_makefiles := $(call all-subdir-makefiles)
subdir_makefiles := $(call all-makefiles-under,$(TOP))
endif # FIND_MAKEFILE_PY

$(foreach mk, $(subdir_makefiles), $(info including $(mk) ...)$(eval include $(mk)))

endif # ONE_SHOT_MAKEFILE

$(DEFAULT_GOAL): $(ALL_MODULES)
	@echo "==== $(DEFAULT_GOAL) ===="

FORCE:
	echo $(ONE_SHOT_MAKEFILE)
	echo $(subdir_makefiles)
