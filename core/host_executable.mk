###########################################################
## Standard rules for building an executable file.
##
## Additional inputs from base_rules.make:
## None.
###########################################################

LOCAL_IS_HOST_MODULE := true

# FIXME: should define in combo
HOST_EXECUTABLE_SUFFIX :=
#HOST_EXECUTABLE_SUFFIX := .exe

# default LOCAL_MODULE_CLASS
ifeq ($(strip $(LOCAL_MODULE_CLASS)),)
LOCAL_MODULE_CLASS := EXECUTABLES
endif
ifeq ($(strip $(LOCAL_MODULE_SUFFIX)),)
LOCAL_MODULE_SUFFIX := $(HOST_EXECUTABLE_SUFFIX)
endif

#######################################
include $(BUILD_BINARY)
#######################################

#$(LOCAL_BUILT_MODULE): $(all_objects) $(all_libraries)
#	$(transform-host-o-to-executable)
# TODO: use makefile func

# FIXED: opt rule relationship
#$(c_binary): $(c_objects)
# FIXED: opt c_objects --> all_objects
$(warning all_objects == $(all_objects))
$(warning all_libraries == $(all_libraries))
$(LOCAL_BUILT_MODULE): $(all_objects) $(all_libraries)
#	@echo '>>> Linking file: $^'
	@mkdir -p $(dir $@)
	@echo "host Executable: $(PRIVATE_MODULE) ($@)"
#	$(CC) $(CFLAGS) -o $@ $^
	$(hide) $(PRIVATE_CXX) -o $@ $(PRIVATE_ALL_OBJECTS) -Wl,--whole-archive $(call normalize-host-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) -Wl,--no-whole-archive $(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) $(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) $(HOST_GLOBAL_LD_DIRS) $(PRIVATE_LDLIBS) -Wl,-rpath-link=$(HOST_OUT_INTERMEDIATE_LIBRARIES) -Wl,-rpath,\$$ORIGIN/../lib
# TODONE: replace $^ --> $(PRIVATE_ALL_OBJECTS) to support additional lib (in binary.mk)
# NOTE: HOST_GLOBAL_LD_DIRS := -L$(HOST_OUT_INTERMEDIATE_LIBRARIES)
# FIXME: when bin do NOT need lib ld flag link "-l -L" should null
#	@echo '>>> Finished building target: $@'
