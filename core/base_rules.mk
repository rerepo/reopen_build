###########################################################
## Common instructions for a generic module.
###########################################################

LOCAL_MODULE := $(strip $(LOCAL_MODULE))
ifeq ($(LOCAL_MODULE),)
  $(error $(LOCAL_PATH): LOCAL_MODULE is not defined)
endif

ifneq (true,$(LOCAL_UNINSTALLABLE_MODULE))
LOCAL_MODULE_PATH := $(strip $(LOCAL_MODULE_PATH))
ifeq ($(LOCAL_MODULE_PATH),)
#install_path_var := $(my_prefix)OUT$(partition_tag)_$(LOCAL_MODULE_CLASS)
# FIXME: define right path
  OUT := out
  install_path_var := OUT
  ifeq (true,$(LOCAL_PRIVILEGED_MODULE))
    install_path_var := $(install_path_var)_PRIVILEGED
  endif

  LOCAL_MODULE_PATH := $($(install_path_var))
  ifeq ($(strip $(LOCAL_MODULE_PATH)),)
    $(error $(LOCAL_PATH): unhandled install path "$(install_path_var)")
  endif
endif
endif # not LOCAL_UNINSTALLABLE_MODULE

ifneq ($(strip $(LOCAL_BUILT_MODULE)$(LOCAL_INSTALLED_MODULE)),)
  $(error $(LOCAL_PATH): LOCAL_BUILT_MODULE and LOCAL_INSTALLED_MODULE must not be defined by component makefiles)
endif

#intermediates := $(call local-intermediates-dir)
intermediates := $(LOCAL_PATH)/out
# TODO: define out dir
# NOTE: intermediates != LOCAL_PATH, otherwise clean self

###########################################################
# Pick a name for the intermediate and final targets
###########################################################
ifndef LOCAL_MODULE_STEM
  LOCAL_MODULE_STEM := $(LOCAL_MODULE)
endif

ifndef LOCAL_BUILT_MODULE_STEM
  LOCAL_BUILT_MODULE_STEM := $(LOCAL_MODULE_STEM)$(LOCAL_MODULE_SUFFIX)
endif

ifndef LOCAL_INSTALLED_MODULE_STEM
  LOCAL_INSTALLED_MODULE_STEM := $(LOCAL_MODULE_STEM)$(LOCAL_MODULE_SUFFIX)
endif

# OVERRIDE_BUILT_MODULE_PATH is only allowed to be used by the
# internal SHARED_LIBRARIES build files.
built_module_path := $(intermediates)
LOCAL_BUILT_MODULE := $(built_module_path)/$(LOCAL_BUILT_MODULE_STEM)
built_module_path :=

ifneq (true,$(LOCAL_UNINSTALLABLE_MODULE))
  LOCAL_INSTALLED_MODULE := $(LOCAL_MODULE_PATH)/$(LOCAL_INSTALLED_MODULE_STEM)
endif

# Assemble the list of targets to create PRIVATE_ variables for.
LOCAL_INTERMEDIATE_TARGETS += $(LOCAL_BUILT_MODULE)
# TODO: why += ???

###########################################################
## make clean- targets
###########################################################
cleantarget := clean-$(LOCAL_MODULE)
$(cleantarget) : PRIVATE_MODULE := $(LOCAL_MODULE)
$(cleantarget) : PRIVATE_CLEAN_FILES := \
    $(LOCAL_BUILT_MODULE) \
    $(LOCAL_INSTALLED_MODULE) \
    $(intermediates)
# FIXME: clean project self ?!
$(cleantarget)::
	@echo "Clean: $(PRIVATE_MODULE)"
	$(hide) rm -rf $(PRIVATE_CLEAN_FILES)
# TODO: support command hide

###########################################################
## Common definitions for module.
###########################################################

# Propagate local configuration options to this target.
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_PATH:=$(LOCAL_PATH)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_AAPT_FLAGS:= $(LOCAL_AAPT_FLAGS)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_JAVA_LIBRARIES:= $(LOCAL_JAVA_LIBRARIES)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_MANIFEST_PACKAGE_NAME:= $(LOCAL_MANIFEST_PACKAGE_NAME)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_MANIFEST_INSTRUMENTATION_FOR:= $(LOCAL_MANIFEST_INSTRUMENTATION_FOR)

$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_ALL_JAVA_LIBRARIES:= $(full_java_libs)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_IS_HOST_MODULE := $(LOCAL_IS_HOST_MODULE)
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_HOST:= $(my_host)

$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_INTERMEDIATES_DIR:= $(intermediates)

# Tell the module and all of its sub-modules who it is.
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_MODULE:= $(LOCAL_MODULE)

# Provide a short-hand for building this module.
# We name both BUILT and INSTALLED in case
# LOCAL_UNINSTALLABLE_MODULE is set.
.PHONY: $(LOCAL_MODULE)
#$(LOCAL_MODULE): $(LOCAL_BUILT_MODULE) $(LOCAL_INSTALLED_MODULE)
$(LOCAL_MODULE): $(LOCAL_BUILT_MODULE)
# TODO: add rule of LOCAL_INSTALLED_MODULE (acp)

###########################################################
## Register with ALL_MODULES
###########################################################

ALL_MODULES += $(LOCAL_MODULE)
#ALL_MODULES += $(LOCAL_PATH)/$(LOCAL_MODULE)
