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
