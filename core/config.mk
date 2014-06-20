# ###############################################################
# Build system internal files
# ###############################################################

BUILD_COMBOS := $(BUILD_SYSTEM)/combo

CLEAR_VARS := $(BUILD_SYSTEM)/clear_vars.mk
BUILD_EXECUTABLE := $(BUILD_SYSTEM)/binary.mk

BUILD_BASE_RULES := $(BUILD_SYSTEM)/base_rules.mk

# ---------------------------------------------------------------
# Define most of the global variables.  These are the ones that
# are specific to the user's build configuration.
include $(BUILD_SYSTEM)/envsetup.mk
