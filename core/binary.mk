###########################################################
## Standard rules for building binary object files from
## asm/c/cpp/yacc/lex source files.
##
## The list of object files is exported in $(all_objects).
###########################################################

#######################################
include $(BUILD_BASE_RULES)
#######################################

###########################################################
## Define PRIVATE_ variables used by multiple module types
###########################################################
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_NO_DEFAULT_COMPILER_FLAGS := \
    $(strip $(LOCAL_NO_DEFAULT_COMPILER_FLAGS))

ifeq ($(strip $(LOCAL_CC)),)
  ifeq ($(strip $(LOCAL_CLANG)),true)
    LOCAL_CC := $(CLANG)
  else
    LOCAL_CC := $($(my_prefix)CC)
  endif
endif
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CC := $(LOCAL_CC)

ifeq ($(strip $(LOCAL_CXX)),)
  ifeq ($(strip $(LOCAL_CLANG)),true)
    LOCAL_CXX := $(CLANG_CXX)
  else
    LOCAL_CXX := $($(my_prefix)CXX)
  endif
endif
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CXX := $(LOCAL_CXX)

# TODO: support a mix of standard extensions so that this isn't necessary
LOCAL_CPP_EXTENSION := $(strip $(LOCAL_CPP_EXTENSION))
ifeq ($(LOCAL_CPP_EXTENSION),)
  LOCAL_CPP_EXTENSION := .cpp
endif
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CPP_EXTENSION := $(LOCAL_CPP_EXTENSION)

# Certain modules like libdl have to have symbols resolved at runtime and blow
# up if --no-undefined is passed to the linker.
ifeq ($(strip $(LOCAL_NO_DEFAULT_COMPILER_FLAGS)),)
ifeq ($(strip $(LOCAL_ALLOW_UNDEFINED_SYMBOLS)),)
  LOCAL_LDFLAGS := $(LOCAL_LDFLAGS) $($(my_prefix)NO_UNDEFINED_LDFLAGS)
endif
endif
$(warning LOCAL_LDFLAGS == $(LOCAL_LDFLAGS))

# TODO: when static lib occur search loop ???
ifeq (true,$(LOCAL_GROUP_STATIC_LIBRARIES))
$(LOCAL_BUILT_MODULE): PRIVATE_GROUP_STATIC_LIBRARIES := true
else
$(LOCAL_BUILT_MODULE): PRIVATE_GROUP_STATIC_LIBRARIES :=
endif

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
so_suffix := $($(my_prefix)SHLIB_SUFFIX)
a_suffix := $($(my_prefix)STATIC_LIB_SUFFIX)
#$(warning so_suffix == $(so_suffix))
#$(warning a_suffix == $(a_suffix))

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
# NOTE: below echo define in definitions.mk like transform-c-to-o-no-deps
	@echo "target $(PRIVATE_ARM_MODE) C: $(PRIVATE_MODULE) <= $<"
#	$(CC) $(CFLAGS) -o $@ -c $<
#	gcc -o $@ -c $< -MMD -MF $(patsubst %.o,%.d,$@) $(addprefix -I ,$(PRIVATE_C_INCLUDES))
	$(hide) $(PRIVATE_CC) -o $@ -c -fPIC $< -MMD -MF $(patsubst %.o,%.d,$@) $(addprefix -I ,$(PRIVATE_C_INCLUDES))
#	gcc -o $@ -c $< -MMD -MP -MF $(patsubst %.o,%.d,$@) -MT $(patsubst %.o,%.d,$@)
	@echo ' '

-include $(c_deps)
