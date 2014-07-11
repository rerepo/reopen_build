# Configuration for builds hosted on linux-x86.
# Included by combo/select.mk

# $(1): The file to check
define get-file-size
stat --format "%s" "$(1)" | tr -d '\n'
endef

# NOTE: HOST_SHLIB_SUFFIX use by host_shared_library.mk
#HOST_SHLIB_SUFFIX :=
#HOST_EXECUTABLE_SUFFIX :=
# FIXED: EXECUTABLE_SUFFIX already define in select.mk like $(combo_target)EXECUTABLE_SUFFIX

# Previously the prebiult host toolchain is used only for the sdk build,
# that's why we have "sdk" in the path name.
ifeq ($(strip $(HOST_TOOLCHAIN_PREFIX)),)
HOST_TOOLCHAIN_PREFIX := prebuilts/tools/gcc-sdk
endif
$(warning HOST_TOOLCHAIN_PREFIX == $(HOST_TOOLCHAIN_PREFIX))

# Don't do anything if the toolchain is not there
ifneq (,$(strip $(wildcard $(HOST_TOOLCHAIN_PREFIX)/gcc)))
HOST_CC  := $(HOST_TOOLCHAIN_PREFIX)/gcc
HOST_CXX := $(HOST_TOOLCHAIN_PREFIX)/g++
HOST_AR  := $(HOST_TOOLCHAIN_PREFIX)/ar
endif # $(HOST_TOOLCHAIN_PREFIX)/gcc exists
$(warning HOST_CC == $(HOST_CC))

ifneq ($(strip $(BUILD_HOST_64bit)),)
# By default we build everything in 32-bit, because it gives us
# more consistency between the host tools and the target.
# BUILD_HOST_64bit=1 overrides it for tool like emulator
# which can benefit from 64-bit host arch.
HOST_GLOBAL_CFLAGS += -m64
HOST_GLOBAL_LDFLAGS += -m64
else
# We expect SSE3 floating point math.
HOST_GLOBAL_CFLAGS += -mstackrealign -msse3 -mfpmath=sse -m32
HOST_GLOBAL_LDFLAGS += -m32
endif # BUILD_HOST_64bit

ifneq ($(strip $(BUILD_HOST_static)),)
# Statically-linked binaries are desirable for sandboxed environment
HOST_GLOBAL_LDFLAGS += -static
endif # BUILD_HOST_static

# FIXME: HOST_GLOBAL_CFLAGS should use by definitions.mk
#HOST_GLOBAL_CFLAGS += -fPIC \
    -include $(call select-android-config-h,linux-x86)

# Disable new longjmp in glibc 2.11 and later. See bug 2967937.
#HOST_GLOBAL_CFLAGS += -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0
# TODO: whether need ???

# FIXME: HOST_NO_UNDEFINED_LDFLAGS should use by binary.mk
HOST_NO_UNDEFINED_LDFLAGS := -Wl,--no-undefined
