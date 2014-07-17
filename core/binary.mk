###########################################################
## Standard rules for building binary object files from
## asm/c/cpp/yacc/lex source files.
##
## The list of object files is exported in $(all_objects).
###########################################################

##################################################
# Compute the dependency of the shared libraries
##################################################
# On the target, we compile with -nostdlib, so we must add in the
# default system shared libraries, unless they have requested not
# to by supplying a LOCAL_SYSTEM_SHARED_LIBRARIES value.  One would
# supply that, for example, when building libc itself.
ifdef LOCAL_IS_HOST_MODULE
  ifeq ($(LOCAL_SYSTEM_SHARED_LIBRARIES),none)
      LOCAL_SYSTEM_SHARED_LIBRARIES :=
  endif
else
  ifeq ($(LOCAL_SYSTEM_SHARED_LIBRARIES),none)
      LOCAL_SYSTEM_SHARED_LIBRARIES := $(TARGET_DEFAULT_SYSTEM_SHARED_LIBRARIES)
  endif
endif

# TODO: what relation with LOCAL_SDK_VERSION and TARGET_DEFAULT_SYSTEM_SHARED_LIBRARIES ???
ifdef LOCAL_SDK_VERSION
  # Get the list of INSTALLED libraries as module names.
  # We cannot compute the full path of the LOCAL_SHARED_LIBRARIES for
  # they may cusomize their install path with LOCAL_MODULE_PATH
  installed_shared_library_module_names := \
      $(LOCAL_SHARED_LIBRARIES)
else
  installed_shared_library_module_names := \
      $(LOCAL_SYSTEM_SHARED_LIBRARIES) $(LOCAL_SHARED_LIBRARIES)
endif
installed_shared_library_module_names := $(sort $(installed_shared_library_module_names))
# TODO: The real dependency and Import includes
ifndef LOCAL_IS_HOST_MODULE
$(warning installed_shared_library_module_names == $(installed_shared_library_module_names))
endif

#######################################
include $(BUILD_BASE_RULES)
#######################################

###########################################################
## Define PRIVATE_ variables from global vars
###########################################################
ifdef LOCAL_SDK_VERSION
my_target_project_includes :=
my_target_c_includes := $(my_ndk_stl_include_path) $(my_ndk_version_root)/usr/include
else
my_target_project_includes := $(TARGET_PROJECT_INCLUDES)
my_target_c_includes := $(TARGET_C_INCLUDES)
endif # LOCAL_SDK_VERSION

ifeq ($(LOCAL_CLANG),true)
my_target_global_cflags := $(TARGET_GLOBAL_CLANG_FLAGS)
my_target_c_includes += $(CLANG_CONFIG_EXTRA_TARGET_C_INCLUDES)
else
my_target_global_cflags := $(TARGET_GLOBAL_CFLAGS)
endif # LOCAL_CLANG

ifndef LOCAL_IS_HOST_MODULE
$(warning my_target_project_includes == $(my_target_project_includes))
$(warning my_target_c_includes == $(my_target_c_includes))
$(warning my_target_global_cflags == $(my_target_global_cflags))
$(warning TARGET_GLOBAL_CPPFLAGS == $(TARGET_GLOBAL_CPPFLAGS))
endif

$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_TARGET_PROJECT_INCLUDES := $(my_target_project_includes)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_TARGET_C_INCLUDES := $(my_target_c_includes)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_TARGET_GLOBAL_CFLAGS := $(my_target_global_cflags)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_TARGET_GLOBAL_CPPFLAGS := $(TARGET_GLOBAL_CPPFLAGS)

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
# NOTE: when NOT define LOCAL_NO_DEFAULT_COMPILER_FLAGS and LOCAL_ALLOW_UNDEFINED_SYMBOLS
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
## Define per-module debugging flags.  Users can turn on
## debugging for a particular module by setting DEBUG_MODULE_ModuleName
## to a non-empty value in their environment or buildspec.mk,
## and setting HOST_/TARGET_CUSTOM_DEBUG_CFLAGS to the
## debug flags that they want to use.
###########################################################
ifdef DEBUG_MODULE_$(strip $(LOCAL_MODULE))
  debug_cflags := $($(my_prefix)CUSTOM_DEBUG_CFLAGS)
else
  debug_cflags :=
endif


###########################################################
## Stuff source generated from one-off tools
###########################################################
$(LOCAL_GENERATED_SOURCES): PRIVATE_MODULE := $(LOCAL_MODULE)

ALL_GENERATED_SOURCES += $(LOCAL_GENERATED_SOURCES)


###########################################################
## o: Include generated .o files in output.
###########################################################

gen_o_objects := $(filter %.o,$(LOCAL_GENERATED_SOURCES))

###########################################################
## C: Compile .c files to .o.
###########################################################

#c_binary := $(LOCAL_PATH)/$(LOCAL_MODULE)
#c_objects := $(patsubst %.c,$(intermediates)/%.o,$(LOCAL_SRC_FILES))
#c_deps := $(patsubst %.c,$(intermediates)/%.d,$(LOCAL_SRC_FILES))

# NOTE: must filter %.c otherwise strip prebuilt module will become object
c_normal_sources := $(filter %.c,$(LOCAL_SRC_FILES))
c_normal_objects := $(addprefix $(intermediates)/,$(c_normal_sources:.c=.o))

c_objects        := $(c_arm_objects) $(c_normal_objects)

#$(warning c_binary == $(c_binary))
$(warning c_objects == $(c_objects))
#$(warning c_deps == $(c_deps))

ifneq ($(strip $(c_objects)),)
$(c_objects): $(intermediates)/%.o: $(TOPDIR)$(LOCAL_PATH)/%.c
	$(transform-$(PRIVATE_HOST)c-to-o)
# NOTE: below echo define in definitions.mk like transform-c-to-o-no-deps
#	@echo "target $(PRIVATE_ARM_MODE) C: $(PRIVATE_MODULE) <= $<"
#	$(hide) $(PRIVATE_CC) -o $@ -c -fPIC $< -MMD -MF $(patsubst %.o,%.d,$@) $(addprefix -I ,$(PRIVATE_C_INCLUDES))
-include $(c_objects:%.o=%.d)
endif

###########################################################
## C: Compile generated .c files to .o.
###########################################################

gen_c_sources := $(filter %.c,$(LOCAL_GENERATED_SOURCES))
gen_c_objects := $(gen_c_sources:%.c=%.o)

$(warning gen_c_objects == $(gen_c_objects))

ifneq ($(strip $(gen_c_objects)),)
# Compile all generated files as thumb.
# TODO: support compiling certain generated files as arm.
$(gen_c_objects): PRIVATE_ARM_MODE := $(normal_objects_mode)
$(gen_c_objects): PRIVATE_ARM_CFLAGS := $(normal_objects_cflags)
#$(gen_c_objects): $(intermediates)/%.o: $(intermediates)/%.c $(yacc_cpps) $(proto_generated_headers) \
    $(LOCAL_ADDITIONAL_DEPENDENCIES) \
    | $(my_compiler_dependencies)
# TODO: yacc_cpps ???
$(gen_c_objects): $(intermediates)/%.o: $(intermediates)/%.c $(yacc_cpps) \
    $(LOCAL_ADDITIONAL_DEPENDENCIES)
	$(transform-$(PRIVATE_HOST)c-to-o)
#-include $(gen_c_objects:%.o=%.P)
-include $(gen_c_objects:%.o=%.d)
endif


####################################################
## Import includes
####################################################
import_includes := $(intermediates)/import_includes
import_includes_deps := $(strip \
    $(foreach l, $(installed_shared_library_module_names), \
      $(call intermediates-dir-for,SHARED_LIBRARIES,$(l),$(LOCAL_IS_HOST_MODULE))/export_includes) \
    $(foreach l, $(LOCAL_STATIC_LIBRARIES) $(LOCAL_WHOLE_STATIC_LIBRARIES), \
      $(call intermediates-dir-for,STATIC_LIBRARIES,$(l),$(LOCAL_IS_HOST_MODULE))/export_includes))
$(import_includes) : $(import_includes_deps)
	@echo Import includes file: $@
	$(hide) mkdir -p $(dir $@) && rm -f $@
ifdef import_includes_deps
	$(hide) for f in $^; do \
	  cat $$f >> $@; \
	done
else
	$(hide) touch $@
endif


###########################################################
## Common object handling.
###########################################################

# some rules depend on asm_objects being first.  If your code depends on
# being first, it's reasonable to require it to be assembly
normal_objects := \
    $(c_objects) \
    $(gen_c_objects)
#    $(asm_objects) \
#    $(gen_asm_objects) \
#    $(cpp_objects) \
#    $(gen_cpp_objects) \
#    $(c_objects) \
#    $(gen_c_objects) \
#    $(addprefix $(TOPDIR)$(LOCAL_PATH)/,$(LOCAL_PREBUILT_OBJ_FILES))
# TODO: PREBUILT_OBJ_FILES ???

all_objects := $(normal_objects) $(gen_o_objects)
$(warning all_objects == $(all_objects))

# FIXME: whether current include ???
#LOCAL_C_INCLUDES += $(TOPDIR)$(LOCAL_PATH) $(intermediates)

# all_objects includes gen_o_objects which were part of LOCAL_GENERATED_SOURCES;
# use normal_objects here to avoid creating circular dependencies. This assumes
# that custom build rules which generate .o files don't consume other generated
# sources as input (or if they do they take care of that dependency themselves).
$(normal_objects) : | $(LOCAL_GENERATED_SOURCES)
# NOTE: normal_objects depend LOCAL_GENERATED_SOURCES
$(all_objects) : | $(import_includes)
#ALL_C_CPP_ETC_OBJECTS += $(all_objects)
# TODO: ETC ???


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


# FIXED: temp use "dont_bother" defined in main.mk
#ifneq ($(dont_bother),true)

###########################################################
# Rule-specific variable definitions
###########################################################
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CFLAGS := $(LOCAL_CFLAGS)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_CPPFLAGS := $(LOCAL_CPPFLAGS)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_DEBUG_CFLAGS := $(debug_cflags)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_C_INCLUDES := $(LOCAL_C_INCLUDES)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_IMPORT_INCLUDES := $(import_includes)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_LDFLAGS := $(LOCAL_LDFLAGS)
$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_LDLIBS := $(LOCAL_LDLIBS)

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


###########################################################
# Export includes
###########################################################
export_includes := $(intermediates)/export_includes
$(export_includes): PRIVATE_EXPORT_C_INCLUDE_DIRS := $(LOCAL_EXPORT_C_INCLUDE_DIRS)
$(export_includes) : $(LOCAL_MODULE_MAKEFILE)
	@echo Export includes file: $< -- $@
	$(hide) mkdir -p $(dir $@) && rm -f $@
ifdef LOCAL_EXPORT_C_INCLUDE_DIRS
	$(hide) for d in $(PRIVATE_EXPORT_C_INCLUDE_DIRS); do \
	        echo "-I $$d" >> $@; \
	        done
else
	$(hide) touch $@
endif

# Make sure export_includes gets generated when you are running mm/mmm
$(LOCAL_BUILT_MODULE) : | $(export_includes)
