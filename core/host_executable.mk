###########################################################
## Standard rules for building an executable file.
##
## Additional inputs from base_rules.make:
## None.
###########################################################

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
	gcc -o $@ $^
# TODO: replace $^ --> $(PRIVATE_ALL_OBJECTS) to support additional lib (in binary.mk)
#	@echo '>>> Finished building target: $@'
