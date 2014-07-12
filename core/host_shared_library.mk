###########################################################
## Standard rules for building a normal shared library.
##
## Additional inputs from base_rules.make:
## None.
##
## LOCAL_MODULE_SUFFIX will be set for you.
###########################################################

LOCAL_IS_HOST_MODULE := true

# FIXED: should define in combo
#HOST_SHLIB_SUFFIX := .so

ifeq ($(strip $(LOCAL_MODULE_CLASS)),)
LOCAL_MODULE_CLASS := SHARED_LIBRARIES
endif
ifeq ($(strip $(LOCAL_MODULE_SUFFIX)),)
LOCAL_MODULE_SUFFIX := $(HOST_SHLIB_SUFFIX)
endif
ifneq ($(strip $(OVERRIDE_BUILT_MODULE_PATH)),)
$(error $(LOCAL_PATH): Illegal use of OVERRIDE_BUILT_MODULE_PATH)
endif
ifneq ($(strip $(LOCAL_MODULE_STEM)$(LOCAL_BUILT_MODULE_STEM)),)
$(error $(LOCAL_PATH): Cannot set module stem for a library)
endif

# Put the built modules of all shared libraries in a common directory
# to simplify the link line.
OVERRIDE_BUILT_MODULE_PATH := $(HOST_OUT_INTERMEDIATE_LIBRARIES)

#######################################
include $(BUILD_BINARY)
#######################################

#$(LOCAL_BUILT_MODULE): $(all_objects) $(all_libraries) $(LOCAL_ADDITIONAL_DEPENDENCIES)
#	$(transform-host-o-to-shared-lib)
$(LOCAL_BUILT_MODULE): $(all_objects) $(all_libraries) $(LOCAL_ADDITIONAL_DEPENDENCIES)
	@mkdir -p $(dir $@)
	@echo "host SharedLib: $(PRIVATE_MODULE) ($@)"
	$(hide) $(PRIVATE_CXX) -o $@ -shared -Wl,-soname,$(notdir $@) $(PRIVATE_ALL_OBJECTS) -Wl,--whole-archive $(call normalize-host-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) -Wl,--no-whole-archive $(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) $(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) $(HOST_GLOBAL_LD_DIRS) $(PRIVATE_LDLIBS) -Wl,-rpath-link=$(HOST_OUT_INTERMEDIATE_LIBRARIES) -Wl,-rpath,\$$ORIGIN/../lib
