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
#$(LOCAL_INTERMEDIATE_TARGETS): PRIVATE_ALL_OBJECTS := $(all_objects)


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
