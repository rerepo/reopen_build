#######################################
include $(BUILD_BASE_RULES)
#######################################

###########################################################
## C: Compile .c files to .o.
###########################################################

#c_binary := $(LOCAL_PATH)/$(LOCAL_MODULE)
c_objects := $(patsubst %.c,$(intermediates)/%.o,$(LOCAL_SRC_FILES))
c_deps := $(patsubst %.c,$(intermediates)/%.d,$(LOCAL_SRC_FILES))

#$(warning c_binary == $(c_binary))
$(warning c_objects == $(c_objects))
#$(warning c_deps == $(c_deps))

###########################################################
## Common object handling.
###########################################################

# some rules depend on asm_objects being first.  If your code depends on
# being first, it's reasonable to require it to be assembly
normal_objects := $(c_objects)
#    $(asm_objects) \
#    $(gen_asm_objects) \
#    $(cpp_objects) \
#    $(gen_cpp_objects) \
#    $(c_objects) \
#    $(gen_c_objects) \
#    $(addprefix $(TOPDIR)$(LOCAL_PATH)/,$(LOCAL_PREBUILT_OBJ_FILES))

all_objects := $(normal_objects) $(gen_o_objects)

# FIXME: whether current include ???
#LOCAL_C_INCLUDES += $(TOPDIR)$(LOCAL_PATH) $(intermediates)

###########################################################
# Standard library handling.
###########################################################

# Get the list of BUILT libraries, which are under
# various intermediates directories.
# FIXED: should define in combo
#so_suffix := .so
#a_suffix := .a
so_suffix := $($(my_prefix)SHLIB_SUFFIX)
a_suffix := $($(my_prefix)STATIC_LIB_SUFFIX)

$(warning so_suffix == $(so_suffix))
$(warning a_suffix == $(a_suffix))

built_shared_libraries := \
    $(addprefix $($(my_prefix)OUT_INTERMEDIATE_LIBRARIES)/, \
      $(addsuffix $(so_suffix), \
        $(LOCAL_SHARED_LIBRARIES)))
#built_shared_libraries := $(addprefix $(intermediates)/,$(addsuffix $(so_suffix),$(LOCAL_SHARED_LIBRARIES)))

$(warning LOCAL_SHARED_LIBRARIES == $(LOCAL_SHARED_LIBRARIES))
$(warning built_shared_libraries == $(built_shared_libraries))

built_static_libraries := \
    $(foreach lib,$(LOCAL_STATIC_LIBRARIES), \
      $(call intermediates-dir-for, \
        STATIC_LIBRARIES,$(lib),$(LOCAL_IS_HOST_MODULE))/$(lib)$(a_suffix))

$(warning LOCAL_STATIC_LIBRARIES == $(LOCAL_STATIC_LIBRARIES))
$(warning built_static_libraries == $(built_static_libraries))

built_whole_libraries := \
    $(foreach lib,$(LOCAL_WHOLE_STATIC_LIBRARIES), \
      $(call intermediates-dir-for, \
        STATIC_LIBRARIES,$(lib),$(LOCAL_IS_HOST_MODULE))/$(lib)$(a_suffix))

$(warning LOCAL_WHOLE_STATIC_LIBRARIES == $(LOCAL_WHOLE_STATIC_LIBRARIES))
$(warning built_whole_libraries == $(built_whole_libraries))

#$(DEFAULT_GOAL): $(c_binary)
#$(DEFAULT_GOAL):
define xxxxxxxxx
	@echo "==== $(DEFAULT_GOAL) ===="
	@echo $(MAKECMDGOALS)
	@echo $(LOCAL_PATH)
	@echo $(c_binary)
	@echo $(c_objects)
	@echo $(c_deps)
endef

# FIXED: temp use "dont_bother" defined in main.mk
#ifneq ($(dont_bother),true)

###########################################################
# Rule-specific variable definitions
###########################################################
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_C_INCLUDES := $(LOCAL_C_INCLUDES)
#$(c_binary): PRIVATE_C_INCLUDES := $(LOCAL_C_INCLUDES)

# this is really the way to get the files onto the command line instead
# of using $^, because then LOCAL_ADDITIONAL_DEPENDENCIES doesn't work
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_ALL_SHARED_LIBRARIES := $(built_shared_libraries)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_ALL_STATIC_LIBRARIES := $(built_static_libraries)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_ALL_WHOLE_STATIC_LIBRARIES := $(built_whole_libraries)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_ALL_OBJECTS := $(all_objects)

###########################################################
# Define library dependencies.
###########################################################
# all_libraries is used for the dependencies on LOCAL_BUILT_MODULE.
all_libraries := \
    $(built_shared_libraries) \
    $(built_static_libraries) \
    $(built_whole_libraries)


$(c_objects): $(intermediates)/%.o: $(TOPDIR)$(LOCAL_PATH)/%.c
#	@echo '>>> Building file: $<'
	@mkdir -p $(dir $@)
	@echo "target $(PRIVATE_ARM_MODE) C: $(PRIVATE_MODULE) <= $<"
#	$(CC) $(CFLAGS) -o $@ -c $<
#	gcc -o $@ -c $< -MMD -MF $(patsubst %.o,%.d,$@) $(addprefix -I ,$(PRIVATE_C_INCLUDES))
	gcc -o $@ -c -fPIC $< -MMD -MF $(patsubst %.o,%.d,$@) $(addprefix -I ,$(PRIVATE_C_INCLUDES))
#	gcc -o $@ -c $< -MMD -MP -MF $(patsubst %.o,%.d,$@) -MT $(patsubst %.o,%.d,$@)
	@echo ' '

-include $(c_deps)
