c_binary := $(LOCAL_PATH)/$(LOCAL_MODULE)
c_objects := $(patsubst %.c,$(LOCAL_PATH)/%.o,$(LOCAL_SRC_FILES))


$(DEFAULT_GOAL): $(c_binary)
#$(DEFAULT_GOAL):
	@echo "==== $(DEFAULT_GOAL) ===="
	@echo $(MAKECMDGOALS)
	@echo $(LOCAL_PATH)
	@echo $(c_binary)
	@echo $(c_objects)


$(c_binary): $(c_objects)
#	$(CC) $(CFLAGS) -o $@ $^
	gcc -o $@ $^

$(c_objects): %.o: %.c
#	$(CC) $(CFLAGS) -o $@ -c $<
	gcc -o $@ -c $<


.PHONY: $(DEFAULT_CLEAN)
$(DEFAULT_CLEAN):
	@echo "==== $(DEFAULT_CLEAN) ===="
	@echo $(MAKECMDGOALS)
	rm -f $(c_binary) $(c_objects)

