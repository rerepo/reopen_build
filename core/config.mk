# This is included by the top-level Makefile.
# It sets up standard variables based on the
# current configuration and platform, which
# are not specific to what is being built.

# Standard source directories.
SRC_TARGET_DIR := $(TOPDIR)build/target

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

# Boards may be defined under $(SRC_TARGET_DIR)/board/$(TARGET_DEVICE)
# or under vendor/*/$(TARGET_DEVICE).  Search in both places, but
# make sure only one exists.
# Real boards should always be associated with an OEM vendor.
board_config_mk := \
	$(strip $(wildcard \
		$(SRC_TARGET_DIR)/board/$(TARGET_DEVICE)/BoardConfig.mk \
		$(shell test -d device && find device -maxdepth 4 -path '*/$(TARGET_DEVICE)/BoardConfig.mk') \
		$(shell test -d vendor && find vendor -maxdepth 4 -path '*/$(TARGET_DEVICE)/BoardConfig.mk') \
	))
ifeq ($(board_config_mk),)
  $(error No config file found for TARGET_DEVICE $(TARGET_DEVICE))
endif
ifneq ($(words $(board_config_mk)),1)
  $(error Multiple board config files for TARGET_DEVICE $(TARGET_DEVICE): $(board_config_mk))
endif
include $(board_config_mk)
ifeq ($(TARGET_ARCH),)
  $(error TARGET_ARCH not defined by board config: $(board_config_mk))
endif
TARGET_DEVICE_DIR := $(patsubst %/,%,$(dir $(board_config_mk)))
board_config_mk :=

# Perhaps we should move this block to build/core/Makefile,
# once we don't have TARGET_NO_KERNEL reference in AndroidBoard.mk/Android.mk.
ifneq ($(strip $(TARGET_NO_BOOTLOADER)),true)
  INSTALLED_BOOTLOADER_MODULE := $(PRODUCT_OUT)/bootloader
  ifeq ($(strip $(TARGET_BOOTLOADER_IS_2ND)),true)
    INSTALLED_2NDBOOTLOADER_TARGET := $(PRODUCT_OUT)/2ndbootloader
  else
    INSTALLED_2NDBOOTLOADER_TARGET :=
  endif
else
  INSTALLED_BOOTLOADER_MODULE :=
  INSTALLED_2NDBOOTLOADER_TARGET :=
endif # TARGET_NO_BOOTLOADER
ifneq ($(strip $(TARGET_NO_KERNEL)),true)
  INSTALLED_KERNEL_TARGET := $(PRODUCT_OUT)/kernel
else
  INSTALLED_KERNEL_TARGET :=
endif

# ---------------------------------------------------------------
# include select combo
combo_target := HOST_
include $(BUILD_SYSTEM)/combo/select.mk

# on windows, the tools have .exe at the end, and we depend on the
# host config stuff being done first
# FIXED
combo_target := TARGET_
include $(BUILD_SYSTEM)/combo/select.mk

# Compute TARGET_TOOLCHAIN_ROOT from TARGET_TOOLS_PREFIX
# if only TARGET_TOOLS_PREFIX is passed to the make command.
ifndef TARGET_TOOLCHAIN_ROOT
TARGET_TOOLCHAIN_ROOT := $(patsubst %/, %, $(dir $(TARGET_TOOLS_PREFIX)))
TARGET_TOOLCHAIN_ROOT := $(patsubst %/, %, $(dir $(TARGET_TOOLCHAIN_ROOT)))
TARGET_TOOLCHAIN_ROOT := $(wildcard $(TARGET_TOOLCHAIN_ROOT))
$(warning TARGET_TOOLCHAIN_ROOT == $(TARGET_TOOLCHAIN_ROOT))
endif

# ---------------------------------------------------------------
# Check that the configuration is current.  We check that
# BUILD_ENV_SEQUENCE_NUMBER is current against this value.
# Don't fail if we're called from envsetup, so they have a
# chance to update their environment.

ifeq (,$(strip $(CALLED_FROM_SETUP)))
ifneq (,$(strip $(BUILD_ENV_SEQUENCE_NUMBER)))
ifneq ($(BUILD_ENV_SEQUENCE_NUMBER),$(CORRECT_BUILD_ENV_SEQUENCE_NUMBER))
$(warning BUILD_ENV_SEQUENCE_NUMBER is set incorrectly.)
$(info *** If you use envsetup/lunch/choosecombo:)
$(info ***   - Re-execute envsetup (". envsetup.sh"))
$(info ***   - Re-run lunch or choosecombo)
$(info *** If you use buildspec.mk:)
$(info ***   - Look at buildspec.mk.default to see what has changed)
$(info ***   - Update BUILD_ENV_SEQUENCE_NUMBER to "$(CORRECT_BUILD_ENV_SEQUENCE_NUMBER)")
$(error bailing..)
endif
endif
endif

# ###############################################################
# Set up final options.
# ###############################################################

# FIXME: why aosp use += ???
HOST_GLOBAL_LD_DIRS := -L$(HOST_OUT_INTERMEDIATE_LIBRARIES)

# ---------------------------------------------------------------
# Define for setup
include $(BUILD_SYSTEM)/dumpvar.mk
