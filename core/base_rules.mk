###########################################################
## Common instructions for a generic module.
###########################################################

LOCAL_MODULE := $(strip $(LOCAL_MODULE))
ifeq ($(LOCAL_MODULE),)
  $(error $(LOCAL_PATH): LOCAL_MODULE is not defined)
endif

$(warning $(LOCAL_PATH): +++ $(LOCAL_MODULE) +++)

LOCAL_IS_HOST_MODULE := $(strip $(LOCAL_IS_HOST_MODULE))
ifdef LOCAL_IS_HOST_MODULE
  ifneq ($(LOCAL_IS_HOST_MODULE),true)
    $(error $(LOCAL_PATH): LOCAL_IS_HOST_MODULE must be "true" or empty, not "$(LOCAL_IS_HOST_MODULE)")
  endif
  my_prefix := HOST_
  my_host := host-
else
  my_prefix := TARGET_
  my_host :=
endif

###########################################################
## Validate and define fallbacks for input LOCAL_* variables.
###########################################################

LOCAL_UNINSTALLABLE_MODULE := $(strip $(LOCAL_UNINSTALLABLE_MODULE))

LOCAL_MODULE_CLASS := $(strip $(LOCAL_MODULE_CLASS))
ifneq ($(words $(LOCAL_MODULE_CLASS)),1)
  $(error $(LOCAL_PATH): LOCAL_MODULE_CLASS must contain exactly one word, not "$(LOCAL_MODULE_CLASS)")
endif


ifneq (true,$(LOCAL_UNINSTALLABLE_MODULE))
LOCAL_MODULE_PATH := $(strip $(LOCAL_MODULE_PATH))
ifeq ($(LOCAL_MODULE_PATH),)
  ifdef LOCAL_IS_HOST_MODULE
    partition_tag :=
  else
    # FIXME
    partition_tag :=
  endif
  install_path_var := $(my_prefix)OUT$(partition_tag)_$(LOCAL_MODULE_CLASS)
# FIXED: define right path
#  OUT := out
#  install_path_var := OUT
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

intermediates := $(call local-intermediates-dir)
#intermediates := $(OUT_DIR)/$(LOCAL_PATH)
# TODONE: define out dir
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
OVERRIDE_BUILT_MODULE_PATH := $(strip $(OVERRIDE_BUILT_MODULE_PATH))
ifdef OVERRIDE_BUILT_MODULE_PATH
  ifneq ($(LOCAL_MODULE_CLASS),SHARED_LIBRARIES)
    $(error $(LOCAL_PATH): Illegal use of OVERRIDE_BUILT_MODULE_PATH)
  endif
  built_module_path := $(OVERRIDE_BUILT_MODULE_PATH)
else
  built_module_path := $(intermediates)
endif
LOCAL_BUILT_MODULE := $(built_module_path)/$(LOCAL_BUILT_MODULE_STEM)
built_module_path :=

$(warning LOCAL_BUILT_MODULE == $(LOCAL_BUILT_MODULE))

ifneq (true,$(LOCAL_UNINSTALLABLE_MODULE))
  LOCAL_INSTALLED_MODULE := $(LOCAL_MODULE_PATH)/$(LOCAL_INSTALLED_MODULE_STEM)
  $(warning LOCAL_INSTALLED_MODULE == $(LOCAL_INSTALLED_MODULE))
endif

# Assemble the list of targets to create PRIVATE_ variables for.
LOCAL_INTERMEDIATE_TARGETS += $(LOCAL_BUILT_MODULE)
# TODONE: why += ??? Ans: to create PRIVATE_ variables

###########################################################
## make clean- targets
###########################################################
cleantarget := $(DEFAULT_CLEAN_PREFIX)$(LOCAL_MODULE)
$(cleantarget) : PRIVATE_MODULE := $(LOCAL_MODULE)
$(cleantarget) : PRIVATE_CLEAN_FILES := \
    $(LOCAL_BUILT_MODULE) \
    $(LOCAL_INSTALLED_MODULE) \
    $(intermediates)
# FIXED: $(intermediates) clean project self ?!
# FIXME: $(LOCAL_INSTALLED_MODULE) now is "out/module" and UNINSTALLABLE should be null
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
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_HOST := $(my_host)

$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_INTERMEDIATES_DIR:= $(intermediates)

# Tell the module and all of its sub-modules who it is.
$(LOCAL_INTERMEDIATE_TARGETS) : PRIVATE_MODULE:= $(LOCAL_MODULE)

# Provide a short-hand for building this module.
# We name both BUILT and INSTALLED in case
# LOCAL_UNINSTALLABLE_MODULE is set.
.PHONY: $(LOCAL_MODULE)
$(LOCAL_MODULE): $(LOCAL_BUILT_MODULE) $(LOCAL_INSTALLED_MODULE)
# TODONE: add rule of LOCAL_INSTALLED_MODULE (no acp)


###########################################################
## Module installation rule
###########################################################

ifndef LOCAL_UNINSTALLABLE_MODULE
  # Define a copy rule to install the module.
  # acp and libraries that it uses can't use acp for
  # installation;  hence, LOCAL_ACP_UNAVAILABLE.

$(LOCAL_INSTALLED_MODULE): $(LOCAL_BUILT_MODULE)
	@echo "Install: $@"
	$(copy-file-to-target-with-cp)

endif # !LOCAL_UNINSTALLABLE_MODULE


###########################################################
## Register with ALL_MODULES
###########################################################

ALL_MODULES += $(LOCAL_MODULE)
#ALL_MODULES += $(LOCAL_PATH)/$(LOCAL_MODULE)
