CC := qcc

INCLUDE := -I$(QNX_TARGET)/usr/include
INCLUDE += -I$(QNX_TARGET)/usr/include/freetype2
INCLUDE += -I./external/include

# BB10 libraries
LIBPATHS	:= -L$(QNX_TARGET)/armle-v7/lib
LIBS    	:= -lbps -licui18n -licuuc -lscreen -lm -lfreetype -lclipboard
LIBS    	+= -lconfig

# Defines
DEFINES := -D_FORTIFY_SOURCE=2 -D__PLAYBOOK__ -fstack-protector-strong

# OpenGL libraries
LIBPATHS += -L$(QNX_TARGET)/armle-v7/usr/lib

# Include bundles libs
LIBPATHS += -L./external/lib
LIBS     += -lconfig -lSDL12 -lTouchControlOverlay

# change these as needed (debug right now)
#DEBUGFLAGS	:= -O2
DEBUGFLAGS	:= -O0 -g -DDEBUGMSGS
CFLAGS    	:= $(INCLUDE) -V4.6.3,gcc_ntoarmv7le -Wc,-std=gnu99 $(DEBUGFLAGS)
LDFLAGS   	:= $(LIBPATHS) $(LIBS)
LDOPTS    	:= -Wl,-z,relro -Wl,-z,now

ASSET      	:= Device-Debug
BINARY     	:= Term49
BINARY_PATH	:= $(ASSET)/$(BINARY)

SRCS := $(wildcard src/*.c)
OBJS := $(SRCS:.c=.o )

include ./signing/bbpass

.PHONY: all clean package-debug deploy launch-debug

all: package-debug

$(BINARY): $(OBJS)
	mkdir -p $(ASSET)
	$(CC) $(CFLAGS) $(LDFLAGS) $(LDOPTS) $(OBJS) -o $(BINARY_PATH)

%.o: %.c
	$(CC) $(CFLAGS) -c $(DEFINES) $< -o $@

clean:
	@rm -fv src/*.o
	@rm -fv $(BINARY_PATH)
	@rmdir -v $(ASSET)
	@rm -fv $(BINARY).bar

signing/debugtoken.bar:
	$(error Debug token error: place debug token in signing/debugtoken.bar or see signing/Makefile))

package-debug: $(BINARY) signing/debugtoken.bar
	blackberry-nativepackager -package $(BINARY).bar bar-descriptor.xml -devMode -debugToken signing/debugtoken.bar

signing/ssh-key:
	$(error SSH key error: signing/ssh-key not found. `cd signing` and `make ssh-key`))
connect: signing/ssh-key
	blackberry-connect $(BBIP) -password $(BBPASS) -sshPublicKey signing/ssh-key.pub

BBIP ?= 169.254.0.1

deploy: package-debug
	blackberry-deploy -installApp $(BBIP) -password $(BBPASS) $(BINARY).bar

launch-debug: deploy
	blackberry-deploy -debugNative -device $(BBIP) -password $(BBPASS) -launchApp $(BINARY).bar
	trap '' SIGINT; BINARY_PATH=$(BINARY_PATH) BBIP=$(BBIP) ntoarm-gdb -x scripts/gdb-debug-setup.py

package-release: $(BINARY)
	blackberry-nativepackager -package $(BINARY).bar bar-descriptor.xml

sign: package-release
	blackberry-signer -bbidtoken ./signing/$(BBIDTOKEN) -storepass $(KEYSTOREPASS) -keystore ./signing/$(KEYSTORE) $(BINARY).bar

