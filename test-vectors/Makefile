CLIENT_COOKIE_OBJS=siphash.o client.o
SERVER_COOKIE_OBJS=siphash.o server.o

.SUFFIXES: .c .o .h
.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

all: client-cookie server-cookie

client-cookie: $(CLIENT_COOKIE_OBJS)
	$(CC) $(LDFLAGS) -o $@ $(CLIENT_COOKIE_OBJS)

server-cookie: $(SERVER_COOKIE_OBJS)
	$(CC) $(LDFLAGS) -o $@ $(SERVER_COOKIE_OBJS)

clean:
	rm -f client-cookie $(CLIENT_COOKIE_OBJS) \
	      server-cookie $(SERVER_COOKIE_OBJS)
