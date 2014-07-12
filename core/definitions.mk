##
## Common build system definitions.  Mostly standard
## commands for building various types of targets, which
## are used by others to construct the final targets.
##

# These are variables we use to collect overall lists
# of things being processed.

# Full paths to all of the documentation
ALL_DOCS:=

# The short names of all of the targets in the system.
# For each element of ALL_MODULES, two other variables
# are defined:
#   $(ALL_MODULES.$(target)).BUILT
#   $(ALL_MODULES.$(target)).INSTALLED
# The BUILT variable contains LOCAL_BUILT_MODULE for that
# target, and the INSTALLED variable contains the LOCAL_INSTALLED_MODULE.
# Some targets may have multiple files listed in the BUILT and INSTALLED
# sub-variables.
ALL_MODULES:=

# Full paths to targets that should be added to the "make droid"
# set of installed targets.
ALL_DEFAULT_INSTALLED_MODULES:=

# The list of tags that have been defined by
# LOCAL_MODULE_TAGS.  Each word in this variable maps
# to a corresponding ALL_MODULE_TAGS.<tagname> variable
# that contains all of the INSTALLED_MODULEs with that tag.
ALL_MODULE_TAGS:=

# Similar to ALL_MODULE_TAGS, but contains the short names
# of all targets for a particular tag.  The top-level variable
# won't have the list of tags;  ust ALL_MODULE_TAGS to get
# the list of all known tags.  (This means that this variable
# will always be empty; it's just here as a placeholder for
# its sub-variables.)
ALL_MODULE_NAME_TAGS:=

# Full paths to all prebuilt files that will be copied
# (used to make the dependency on acp)
ALL_PREBUILT:=

# Full path to all files that are made by some tool
ALL_GENERATED_SOURCES:=

# Full path to all asm, C, C++, lex and yacc generated C files.
# These all have an order-only dependency on the copied headers
ALL_C_CPP_ETC_OBJECTS:=

# The list of dynamic binaries that haven't been stripped/compressed/etc.
ALL_ORIGINAL_DYNAMIC_BINARIES:=

# These files go into the SDK
ALL_SDK_FILES:=

# Files for dalvik.  This is often build without building the rest of the OS.
INTERNAL_DALVIK_MODULES:=

# All findbugs xml files
ALL_FINDBUGS_FILES:=

# GPL module license files
ALL_GPL_MODULE_LICENSE_FILES:=

# Target and host installed module's dependencies on shared libraries.
# They are list of "<module_name>:<installed_file>:lib1,lib2...".
TARGET_DEPENDENCIES_ON_SHARED_LIBRARIES :=
HOST_DEPENDENCIES_ON_SHARED_LIBRARIES :=

# Generated class file names for Android resource.
# They are escaped and quoted so can be passed safely to a bash command.
ANDROID_RESOURCE_GENERATED_CLASSES := 'R.class' 'R$$*.class' 'Manifest.class' 'Manifest$$*.class'

###########################################################
## Debugging; prints a variable list to stdout
###########################################################

# $(1): variable name list, not variable values
define print-vars
$(foreach var,$(1), \
  $(info $(var):) \
  $(foreach word,$($(var)), \
    $(info $(space)$(space)$(word)) \
   ) \
 )
endef

###########################################################
## Evaluates to true if the string contains the word true,
## and empty otherwise
## $(1): a var to test
###########################################################

define true-or-empty
$(filter true, $(1))
endef


###########################################################
## Retrieve the directory of the current makefile
###########################################################

# Figure out where we are.
define my-dir
$(strip \
  $(eval LOCAL_MODULE_MAKEFILE := $$(lastword $$(MAKEFILE_LIST))) \
  $(if $(filter $(CLEAR_VARS),$(LOCAL_MODULE_MAKEFILE)), \
    $(error LOCAL_PATH must be set before including $$(CLEAR_VARS)) \
   , \
    $(patsubst %/,%,$(dir $(LOCAL_MODULE_MAKEFILE))) \
   ) \
 )
endef

###########################################################
## Retrieve a list of all makefiles immediately below some directory
###########################################################

define all-makefiles-under
$(shell find $(1) -name $(BUILD_MAKEFILE) | xargs echo)
endef
#$(wildcard $(1)/*/$(BUILD_MAKEFILE))

###########################################################
## Look under a directory for makefiles that don't have parent
## makefiles.
###########################################################

# $(1): directory to search under
# Ignores $(1)/Android.mk
define first-makefiles-under
$(shell build/tools/findleaves.py --prune=$(OUT_DIR) --prune=.repo --prune=.git \
        --mindepth=2 $(1) Android.mk)
endef

###########################################################
## Retrieve a list of all makefiles immediately below your directory
###########################################################

define all-subdir-makefiles
$(call all-makefiles-under,$(call my-dir))
endef

###########################################################
## Look in the named list of directories for makefiles,
## relative to the current directory.
###########################################################

# $(1): List of directories to look for under this directory
define all-named-subdir-makefiles
$(wildcard $(addsuffix /Android.mk, $(addprefix $(call my-dir)/,$(1))))
endef

###########################################################
## Find all of the java files under the named directories.
## Meant to be used like:
##    SRC_FILES := $(call all-java-files-under,src tests)
###########################################################

define all-java-files-under
$(patsubst ./%,%, \
  $(shell cd $(LOCAL_PATH) ; \
          find -L $(1) -name "*.java" -and -not -name ".*") \
 )
endef

###########################################################
## Find all of the java files from here.  Meant to be used like:
##    SRC_FILES := $(call all-subdir-java-files)
###########################################################

define all-subdir-java-files
$(call all-java-files-under,.)
endef

###########################################################
## Find all of the c files under the named directories.
## Meant to be used like:
##    SRC_FILES := $(call all-c-files-under,src tests)
###########################################################

define all-c-files-under
$(patsubst ./%,%, \
  $(shell cd $(LOCAL_PATH) ; \
          find -L $(1) -name "*.c" -and -not -name ".*") \
 )
endef

###########################################################
## Find all of the c files from here.  Meant to be used like:
##    SRC_FILES := $(call all-subdir-c-files)
###########################################################

define all-subdir-c-files
$(call all-c-files-under,.)
endef

###########################################################
## Find all files named "I*.aidl" under the named directories,
## which must be relative to $(LOCAL_PATH).  The returned list
## is relative to $(LOCAL_PATH).
###########################################################

define all-Iaidl-files-under
$(patsubst ./%,%, \
  $(shell cd $(LOCAL_PATH) ; \
          find -L $(1) -name "I*.aidl" -and -not -name ".*") \
 )
endef

###########################################################
## Find all of the "I*.aidl" files under $(LOCAL_PATH).
###########################################################

define all-subdir-Iaidl-files
$(call all-Iaidl-files-under,.)
endef

###########################################################
## Find all of the logtags files under the named directories.
## Meant to be used like:
##    SRC_FILES := $(call all-logtags-files-under,src)
###########################################################

define all-logtags-files-under
$(patsubst ./%,%, \
  $(shell cd $(LOCAL_PATH) ; \
          find -L $(1) -name "*.logtags" -and -not -name ".*") \
  )
endef

###########################################################
## Find all of the .proto files under the named directories.
## Meant to be used like:
##    SRC_FILES := $(call all-proto-files-under,src)
###########################################################

define all-proto-files-under
$(patsubst ./%,%, \
  $(shell cd $(LOCAL_PATH) ; \
          find -L $(1) -name "*.proto" -and -not -name ".*") \
  )
endef

###########################################################
## Find all of the RenderScript files under the named directories.
##  Meant to be used like:
##    SRC_FILES := $(call all-renderscript-files-under,src)
###########################################################

define all-renderscript-files-under
$(patsubst ./%,%, \
  $(shell cd $(LOCAL_PATH) ; \
          find -L $(1) \( -name "*.rs" -or -name "*.fs" \) -and -not -name ".*") \
  )
endef

###########################################################
## Find all of the html files under the named directories.
## Meant to be used like:
##    SRC_FILES := $(call all-html-files-under,src tests)
###########################################################

define all-html-files-under
$(patsubst ./%,%, \
  $(shell cd $(LOCAL_PATH) ; \
          find -L $(1) -name "*.html" -and -not -name ".*") \
 )
endef

###########################################################
## Find all of the html files from here.  Meant to be used like:
##    SRC_FILES := $(call all-subdir-html-files)
###########################################################

define all-subdir-html-files
$(call all-html-files-under,.)
endef

###########################################################
## Find all of the files matching pattern
##    SRC_FILES := $(call find-subdir-files, <pattern>)
###########################################################

define find-subdir-files
$(patsubst ./%,%,$(shell cd $(LOCAL_PATH) ; find -L $(1)))
endef

###########################################################
# find the files in the subdirectory $1 of LOCAL_DIR
# matching pattern $2, filtering out files $3
# e.g.
#     SRC_FILES += $(call find-subdir-subdir-files, \
#                         css, *.cpp, DontWantThis.cpp)
###########################################################

define find-subdir-subdir-files
$(filter-out $(patsubst %,$(1)/%,$(3)),$(patsubst ./%,%,$(shell cd \
            $(LOCAL_PATH) ; find -L $(1) -maxdepth 1 -name $(2))))
endef

###########################################################
## Find all of the files matching pattern
##    SRC_FILES := $(call all-subdir-java-files)
###########################################################

define find-subdir-assets
$(if $(1),$(patsubst ./%,%, \
	$(shell if [ -d $(1) ] ; then cd $(1) ; find ./ -not -name '.*' -and -type f -and -not -type l ; fi)), \
	$(warning Empty argument supplied to find-subdir-assets) \
)
endef

###########################################################
## Find various file types in a list of directories relative to $(LOCAL_PATH)
###########################################################

define find-other-java-files
	$(call find-subdir-files,$(1) -name "*.java" -and -not -name ".*")
endef

define find-other-html-files
	$(call find-subdir-files,$(1) -name "*.html" -and -not -name ".*")
endef

###########################################################
## Scan through each directory of $(1) looking for files
## that match $(2) using $(wildcard).  Useful for seeing if
## a given directory or one of its parents contains
## a particular file.  Returns the first match found,
## starting furthest from the root.
###########################################################

define find-parent-file
$(strip \
  $(eval _fpf := $(wildcard $(foreach f, $(2), $(strip $(1))/$(f)))) \
  $(if $(_fpf),$(_fpf), \
       $(if $(filter-out ./ .,$(1)), \
             $(call find-parent-file,$(patsubst %/,%,$(dir $(1))),$(2)) \
        ) \
   ) \
)
endef

###########################################################
## Function we can evaluate to introduce a dynamic dependency
###########################################################

define add-dependency
$(1): $(2)
endef

###########################################################
## Set up the dependencies for a prebuilt target
##  $(call add-prebuilt-file, srcfile, [targetclass])
###########################################################

define add-prebuilt-file
    $(eval $(include-prebuilt))
endef

define include-prebuilt
    include $$(CLEAR_VARS)
    LOCAL_SRC_FILES := $(1)
    LOCAL_BUILT_MODULE_STEM := $(1)
    LOCAL_MODULE_SUFFIX := $$(suffix $(1))
    LOCAL_MODULE := $$(basename $(1))
    LOCAL_MODULE_CLASS := $(2)
    include $$(BUILD_PREBUILT)
endef

###########################################################
## do multiple prebuilts
##  $(call target class, files ...)
###########################################################

define add-prebuilt-files
    $(foreach f,$(2),$(call add-prebuilt-file,$f,$(1)))
endef


###########################################################
## The intermediates directory.  Where object files go for
## a given target.  We could technically get away without
## the "_intermediates" suffix on the directory, but it's
## nice to be able to grep for that string to find out if
## anyone's abusing the system.
###########################################################

# $(1): target class, like "APPS"
# $(2): target name, like "NotePad"
# $(3): if non-empty, this is a HOST target.
# $(4): if non-empty, force the intermediates to be COMMON
define intermediates-dir-for
$(strip \
    $(eval _idfClass := $(strip $(1))) \
    $(if $(_idfClass),, \
        $(error $(LOCAL_PATH): Class not defined in call to intermediates-dir-for)) \
    $(eval _idfName := $(strip $(2))) \
    $(if $(_idfName),, \
        $(error $(LOCAL_PATH): Name not defined in call to intermediates-dir-for)) \
    $(eval _idfPrefix := $(if $(strip $(3)),HOST,TARGET)) \
    $(if $(filter $(_idfPrefix)-$(_idfClass),$(COMMON_MODULE_CLASSES))$(4), \
        $(eval _idfIntBase := $($(_idfPrefix)_OUT_COMMON_INTERMEDIATES)) \
      , \
        $(eval _idfIntBase := $($(_idfPrefix)_OUT_INTERMEDIATES)) \
     ) \
    $(_idfIntBase)/$(_idfClass)/$(_idfName)_intermediates \
)
endef

# Uses LOCAL_MODULE_CLASS, LOCAL_MODULE, and LOCAL_IS_HOST_MODULE
# to determine the intermediates directory.
#
# $(1): if non-empty, force the intermediates to be COMMON
define local-intermediates-dir
$(strip \
    $(if $(strip $(LOCAL_MODULE_CLASS)),, \
        $(error $(LOCAL_PATH): LOCAL_MODULE_CLASS not defined before call to local-intermediates-dir)) \
    $(if $(strip $(LOCAL_MODULE)),, \
        $(error $(LOCAL_PATH): LOCAL_MODULE not defined before call to local-intermediates-dir)) \
    $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE),$(LOCAL_IS_HOST_MODULE),$(1)) \
)
endef

###########################################################
## Convert "path/to/libXXX.so" to "-lXXX".
## Any "path/to/libXXX.a" elements pass through unchanged.
###########################################################

define normalize-libraries
$(foreach so,$(filter %.so,$(1)),-l$(patsubst lib%.so,%,$(notdir $(so))))\
$(filter-out %.so,$(1))
endef

# TODO: change users to call the common version.
define normalize-host-libraries
$(call normalize-libraries,$(1))
endef

define normalize-target-libraries
$(call normalize-libraries,$(1))
endef


###########################################################
## Commands for running gcc to compile a host C file
###########################################################

# $(1): extra flags
define transform-host-c-or-s-to-o-no-deps
@mkdir -p $(dir $@)
$(hide) $(PRIVATE_CC) \
	$(addprefix -I , $(PRIVATE_C_INCLUDES)) \
	$(addprefix -isystem ,\
	    $(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
	        $(filter-out $(PRIVATE_C_INCLUDES), \
	            $(HOST_PROJECT_INCLUDES) \
	            $(HOST_C_INCLUDES)))) \
	-c \
	$(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
	    $(HOST_GLOBAL_CFLAGS) \
	) \
	$(1) \
	-MMD -MP -MF $(patsubst %.o,%.d,$@) -o $@ $<
endef
#	-MD -MF $(patsubst %.o,%.d,$@) -o $@ $<

define transform-host-c-to-o-no-deps
@echo "host C: $(PRIVATE_MODULE) <= $<"
$(call transform-host-c-or-s-to-o-no-deps, $(PRIVATE_CFLAGS) $(PRIVATE_CONLYFLAGS) $(PRIVATE_DEBUG_CFLAGS))
endef

define transform-host-s-to-o-no-deps
@echo "host asm: $(PRIVATE_MODULE) <= $<"
$(call transform-host-c-or-s-to-o-no-deps, $(PRIVATE_ASFLAGS))
endef

define transform-host-c-to-o
$(transform-host-c-to-o-no-deps)
endef
# TODO: why aosp use [.P] for depend ???
#$(transform-d-to-p)

define transform-host-s-to-o
$(transform-host-s-to-o-no-deps)
$(transform-d-to-p)
endef


###########################################################
## Commands for running ar
###########################################################

define _concat-if-arg2-not-empty
$(if $(2),$(hide) $(1) $(2))
endef

# Split long argument list into smaller groups and call the command repeatedly
# Call the command at least once even if there are no arguments, as otherwise
# the output file won't be created.
#
# $(1): the command without arguments
# $(2): the arguments
define split-long-arguments
$(hide) $(1) $(wordlist 1,500,$(2))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 501,1000,$(2)))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 1001,1500,$(2)))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 1501,2000,$(2)))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 2001,2500,$(2)))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 2501,3000,$(2)))
$(call _concat-if-arg2-not-empty,$(1),$(wordlist 3001,99999,$(2)))
endef


###########################################################
## Commands for running host ar
###########################################################

# FIXED: should in combo
#HOST_AR := ar
#HOST_GLOBAL_ARFLAGS := crsP
# NOTE: PRIVATE_ARFLAGS no define in build system
#PRIVATE_ARFLAGS :=

# $(1): the full path of the source static library.
define _extract-and-include-single-host-whole-static-lib
@echo "preparing StaticLib: $(PRIVATE_MODULE) [including $(1)]"
$(hide) ldir=$(PRIVATE_INTERMEDIATES_DIR)/WHOLE/$(basename $(notdir $(1)))_objs;\
    rm -rf $$ldir; \
    mkdir -p $$ldir; \
    filelist=; \
    for f in `$(HOST_AR) t $(1) | \grep '\.o$$'`; do \
        $(HOST_AR) p $(1) $$f > $$ldir/$$f; \
        filelist="$$filelist $$ldir/$$f"; \
    done ; \
    $(HOST_AR) $(HOST_GLOBAL_ARFLAGS) $(PRIVATE_ARFLAGS) $@ $$filelist

endef

define extract-and-include-host-whole-static-libs
$(foreach lib,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES), \
    $(call _extract-and-include-single-host-whole-static-lib, $(lib)))
endef

# Explicitly delete the archive first so that ar doesn't
# try to add to an existing archive.
define transform-host-o-to-static-lib
@mkdir -p $(dir $@)
@rm -f $@
$(extract-and-include-host-whole-static-libs)
@echo "host StaticLib: $(PRIVATE_MODULE) ($@)"
$(call split-long-arguments,$(HOST_AR) $(HOST_GLOBAL_ARFLAGS) $(PRIVATE_ARFLAGS) $@,$(filter %.o, $^))
endef


###########################################################
## Commands for running gcc to link a shared library or package
###########################################################

# ld just seems to be so finicky with command order that we allow
# it to be overriden en-masse see combo/linux-arm.make for an example.
ifneq ($(HOST_CUSTOM_LD_COMMAND),true)
define transform-host-o-to-shared-lib-inner
$(hide) $(PRIVATE_CXX) \
	-Wl,-rpath-link=$(HOST_OUT_INTERMEDIATE_LIBRARIES) \
	-Wl,-rpath,\$$ORIGIN/../lib \
	-shared -Wl,-soname,$(notdir $@) \
	$(PRIVATE_LDFLAGS) \
	$(HOST_GLOBAL_LD_DIRS) \
	$(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
	   $(HOST_GLOBAL_LDFLAGS) \
	) \
	$(PRIVATE_ALL_OBJECTS) \
	-Wl,--whole-archive \
	$(call normalize-host-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	-Wl,--no-whole-archive \
	$(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--start-group) \
	$(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
	$(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--end-group) \
	$(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
	-o $@ \
	$(PRIVATE_LDLIBS)
endef
endif

define transform-host-o-to-shared-lib
@mkdir -p $(dir $@)
@echo "host SharedLib: $(PRIVATE_MODULE) ($@)"
$(transform-host-o-to-shared-lib-inner)
endef


###########################################################
## Commands for running gcc to link a host executable
###########################################################

ifneq ($(HOST_CUSTOM_LD_COMMAND),true)
define transform-host-o-to-executable-inner
$(hide) $(PRIVATE_CXX) \
	$(PRIVATE_ALL_OBJECTS) \
	-Wl,--whole-archive \
	$(call normalize-host-libraries,$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES)) \
	-Wl,--no-whole-archive \
	$(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--start-group) \
	$(call normalize-host-libraries,$(PRIVATE_ALL_STATIC_LIBRARIES)) \
	$(if $(PRIVATE_GROUP_STATIC_LIBRARIES),-Wl$(comma)--end-group) \
	$(call normalize-host-libraries,$(PRIVATE_ALL_SHARED_LIBRARIES)) \
	-Wl,-rpath-link=$(HOST_OUT_INTERMEDIATE_LIBRARIES) \
	-Wl,-rpath,\$$ORIGIN/../lib \
	$(HOST_GLOBAL_LD_DIRS) \
	$(PRIVATE_LDFLAGS) \
	$(if $(PRIVATE_NO_DEFAULT_COMPILER_FLAGS),, \
		$(HOST_GLOBAL_LDFLAGS) \
	) \
	-o $@ \
	$(PRIVATE_LDLIBS)
endef
endif

define transform-host-o-to-executable
@mkdir -p $(dir $@)
@echo "host Executable: $(PRIVATE_MODULE) ($@)"
$(transform-host-o-to-executable-inner)
endef


###########################################################
## Commands for copying files
###########################################################

# Copy a single file from one place to another,
# preserving permissions and overwriting any existing
# file.
# The same as copy-file-to-target, but use the local
# cp command instead of acp.
define copy-file-to-target-with-cp
@mkdir -p $(dir $@)
$(hide) cp -fp $< $@
endef

###########################################################
## Dump the variables that are associated with targets
###########################################################

define dump-module-variables
@echo all_dependencies=$^
@echo PRIVATE_YACCFLAGS=$(PRIVATE_YACCFLAGS);
@echo PRIVATE_CFLAGS=$(PRIVATE_CFLAGS);
@echo PRIVATE_CPPFLAGS=$(PRIVATE_CPPFLAGS);
@echo PRIVATE_DEBUG_CFLAGS=$(PRIVATE_DEBUG_CFLAGS);
@echo PRIVATE_C_INCLUDES=$(PRIVATE_C_INCLUDES);
@echo PRIVATE_LDFLAGS=$(PRIVATE_LDFLAGS);
@echo PRIVATE_LDLIBS=$(PRIVATE_LDLIBS);
@echo PRIVATE_ARFLAGS=$(PRIVATE_ARFLAGS);
@echo PRIVATE_AAPT_FLAGS=$(PRIVATE_AAPT_FLAGS);
@echo PRIVATE_DX_FLAGS=$(PRIVATE_DX_FLAGS);
@echo PRIVATE_JAVACFLAGS=$(PRIVATE_JAVACFLAGS);
@echo PRIVATE_JAVA_LIBRARIES=$(PRIVATE_JAVA_LIBRARIES);
@echo PRIVATE_ALL_SHARED_LIBRARIES=$(PRIVATE_ALL_SHARED_LIBRARIES);
@echo PRIVATE_ALL_STATIC_LIBRARIES=$(PRIVATE_ALL_STATIC_LIBRARIES);
@echo PRIVATE_ALL_WHOLE_STATIC_LIBRARIES=$(PRIVATE_ALL_WHOLE_STATIC_LIBRARIES);
@echo PRIVATE_ALL_OBJECTS=$(PRIVATE_ALL_OBJECTS);
@echo PRIVATE_NO_CRT=$(PRIVATE_NO_CRT);
endef


###########################################################
## Misc notes
###########################################################

#DEPDIR = .deps
#df = $(DEPDIR)/$(*F)

#SRCS = foo.c bar.c ...

#%.o : %.c
#	@$(MAKEDEPEND); \
#	  cp $(df).d $(df).P; \
#	  sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
#	      -e '/^$$/ d' -e 's/$$/ :/' < $(df).d >> $(df).P; \
#	  rm -f $(df).d
#	$(COMPILE.c) -o $@ $<

#-include $(SRCS:%.c=$(DEPDIR)/%.P)


#%.o : %.c
#	$(COMPILE.c) -MD -o $@ $<
#	@cp $*.d $*.P; \
#	  sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
#	      -e '/^$$/ d' -e 's/$$/ :/' < $*.d >> $*.P; \
#	  rm -f $*.d
