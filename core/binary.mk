c_binary := $(LOCAL_MODULE)
c_objects := $(patsubst %.c,%.o,$(LOCAL_SRC_FILES))

all: $(c_binary)
	echo $(c_binary)

$(c_binary): $(c_objects)
#	$(CC) $(CFLAGS) -o $@ $^
	gcc -o $@ $^

$(c_objects): %.o: %.c
#	$(CC) $(CFLAGS) -o $@ -c $<
	gcc -o $@ -c $<

