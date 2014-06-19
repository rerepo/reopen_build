c_binary := $(LOCAL_PATH)/$(LOCAL_MODULE)
c_objects := $(patsubst %.c,$(LOCAL_PATH)/%.o,$(LOCAL_SRC_FILES))
c_deps := $(patsubst %.c,$(LOCAL_PATH)/%.d,$(LOCAL_SRC_FILES))
ifneq ($(LOCAL_C_INCLUDES),)
c_includes := $(addprefix -I ,$(LOCAL_C_INCLUDES))
#c_includes := $(addprefix -I ,$(addprefix $(LOCAL_PATH)/,$(LOCAL_C_INCLUDES)))
endif # LOCAL_C_INCLUDES

$(DEFAULT_GOAL): $(c_binary)
#$(DEFAULT_GOAL):
	@echo "==== $(DEFAULT_GOAL) ===="
	@echo $(MAKECMDGOALS)
	@echo $(LOCAL_PATH)
	@echo $(c_binary)
	@echo $(c_objects)
	@echo $(c_deps)

$(c_binary): $(c_objects)
	@echo '>>> Linking file: $^'
#	$(CC) $(CFLAGS) -o $@ $^
	gcc -o $@ $^
	@echo '>>> Finished building target: $@'
	@echo ' '

$(c_objects): %.o: %.c
	@echo '>>> Building file: $<'
#	$(CC) $(CFLAGS) -o $@ -c $<
	gcc -o $@ -c $< -MMD -MF $(patsubst %.o,%.d,$@) $(c_includes)
#	gcc -o $@ -c $< -MMD -MP -MF $(patsubst %.o,%.d,$@) -MT $(patsubst %.o,%.d,$@)
	@echo ' '

-include $(c_deps)

.PHONY: $(DEFAULT_CLEAN)
$(DEFAULT_CLEAN):
	@echo "==== $(DEFAULT_CLEAN) ===="
	@echo $(MAKECMDGOALS)
	rm -f $(c_binary) $(c_objects) $(c_deps)

