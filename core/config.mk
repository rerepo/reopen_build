# ###############################################################
# Build system internal files
# ###############################################################

BUILD_COMBOS := $(BUILD_SYSTEM)/combo

CLEAR_VARS := $(BUILD_SYSTEM)/clear_vars.mk
BUILD_HOST_STATIC_LIBRARY := $(BUILD_SYSTEM)/host_static_library.mk
BUILD_HOST_SHARED_LIBRARY := $(BUILD_SYSTEM)/host_shared_library.mk
#BUILD_EXECUTABLE := $(BUILD_SYSTEM)/executable.mk
BUILD_EXECUTABLE := $(BUILD_SYSTEM)/host_executable.mk
BUILD_HOST_EXECUTABLE := $(BUILD_SYSTEM)/host_executable.mk

# Internal makefile invoked by above
BUILD_BINARY := $(BUILD_SYSTEM)/binary.mk
BUILD_BASE_RULES := $(BUILD_SYSTEM)/base_rules.mk

# ---------------------------------------------------------------
# Define most of the global variables.  These are the ones that
# are specific to the user's build configuration.
include $(BUILD_SYSTEM)/envsetup.mk

# ###############################################################
# Set up final options.
# ###############################################################

# FIXME: why aosp use += ???
HOST_GLOBAL_LD_DIRS := -L$(HOST_OUT_INTERMEDIATE_LIBRARIES)
