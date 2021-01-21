# export LD_LIBRARY_PATH=

PHONY : all

TARGET_NAME ?= target/bin/libwebsockets

AS	= $(CROSS_COMPILE)as
LD	= $(CROSS_COMPILE)ld
CC	= $(CROSS_COMPILE)gcc
CPP	= $(CC) -E
AR	= $(CROSS_COMPILE)ar
NM	= $(CROSS_COMPILE)nm
STRIP	= $(CROSS_COMPILE)strip
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump
RANLIB	= $(CROSS_COMPILE)RANLIB

CFLAGS =
CFLAGS += -fPIC -rdynamic -pipe -O2 -Wall
CFLAGS += -I include
CFLAGS += -I ./lib/core-net
#CFLAGS += -I ./lib/event-libs/sdevent
#CFLAGS += -I ./lib/event-libs/libev
#CFLAGS += -I ./lib/event-libs/glib
CFLAGS += -I ./lib/event-libs
#CFLAGS += -I ./lib/event-libs/libevent
#CFLAGS += -I ./lib/event-libs/libuv
#CFLAGS += -I ./lib/event-libs/poll
CFLAGS += -I ./lib/tls
#CFLAGS += -I ./lib/tls/mbedtls
CFLAGS += -I ./lib/tls/openssl
CFLAGS += -I ./lib/core
CFLAGS += -I ./lib/secure-streams
CFLAGS += -I ./lib/abstract
CFLAGS += -I ./lib/abstract/protocols/smtp
CFLAGS += -I ./lib/system/smd
CFLAGS += -I ./lib/system/async-dns
CFLAGS += -I ./lib/system/dhcpclient
CFLAGS += -I ./lib/roles/h2
CFLAGS += -I ./lib/roles/dbus
CFLAGS += -I ./lib/roles/cgi
CFLAGS += -I ./lib/roles/ws
CFLAGS += -I ./lib/roles/raw-proxy
CFLAGS += -I ./lib/roles/http/compression
CFLAGS += -I ./lib/roles/http
CFLAGS += -I ./lib/roles/h1
CFLAGS += -I ./lib/roles/mqtt
CFLAGS += -I ./lib/roles
CFLAGS += -I ./lib/jose
CFLAGS += -I ./lib/jose/jws
CFLAGS += -I ./lib/jose/jwe
CFLAGS += -I ./lib/misc/fts
CFLAGS += -I ./lib/misc/lwsac
CFLAGS += -I ./lib/drivers/led
#CFLAGS += -I ./lib/plat/windows
#CFLAGS += -I ./lib/plat/optee
#CFLAGS += -I ./lib/plat/freertos
CFLAGS += -I ./lib/plat/unix

LDFLAGS = 
LDFLAGS += -fPIC -rdynamic -shared 

export AS LD CC CPP AR NM STRIP OBJCOPY OBJDUMP RANLIB CFLAGS LDFLAGS

TEST_CFLAGS ?= ${CFLAGS}
LINK_PATH := -L libs
LD_LIBS :=

export TEST_CFLAGS LINK_PATH LD_LIBS

MAKEFILE_BUILD := scripts/Makefile.build
MAKEFILE_TEST_BUILD := scripts/Makefile.test.build
export MAKEFILE_BUILD MAKEFILE_TEST_BUILD

dirs := lib/
dirs := ${patsubst %/,%,$(filter %/, $(dirs))}
PHONY += $(dirs)
$(dirs): FORCE
	@make -f ${MAKEFILE_BUILD}  obj=$@

objs := init/main.o

all: $(dirs) ${objs}
	$(CC) ${CFLAGS} ${LINK_PATH} -o ${TARGET_NAME} ${objs} ${LD_LIBS}

test_dirs := tests/
test_dirs := ${patsubst %/,%,$(filter %/, $(test_dirs))}
$(test_dirs): FORCE
	@make -f ${MAKEFILE_TEST_BUILD}  obj=$@
	
test: $(test_dirs) FORCE
	
clean:	FORCE
	@echo  ">>> clean target"
	@rm -f *.bak *.so *.a
	@rm -f ${TARGET_NAME}
	@${shell for dir in `find -maxdepth 3 -type d | grep -v git| grep -v include | grep -v \.si4project`;\
	do rm -f $${dir}/*.o $${dir}/*.bak $${dir}/*.so $${dir}/*.a $${dir}/*.dep;done}
	@${shell cd tests && for i in `find *.c`;do rm -f `echo $$i|sed 's/\.c//g' `;done }

distclean: clean
	@echo ">>> distclean target"
	@rm -fr target/bin/ target/libs/

help: 
	@echo  'Cleaning targets:'
	@echo  '  clean		  - Remove most generated files but keep the config and'
	@echo  '                    enough build support to build external modules'
	@echo  '  mrproper	  - Remove all generated files + config + various backup files'
	@echo  '  distclean	  - mrproper + remove editor backup and patch files'
	@echo  ''
	@exit 0


PHONY += FORCE
FORCE:
