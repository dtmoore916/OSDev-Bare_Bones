PROGRAM=myos.bin
CC=i686-elf-gcc
AS=i686-elf-as

MKDIR_P = mkdir -p
OBJ_DIR = _objs

CFLAGS=-I. -std=gnu99 -ffreestanding -O2 -Wall -Wextra
LDFLAGS=-ffreestanding -O2 -nostdlib -lgcc

DEPS := $(wildcard *.h)

SRC += $(wildcard *.cpp)
OBJ += $(patsubst %.cpp,$(OBJ_DIR)/%.o,$(wildcard *.cpp))

SRC += $(wildcard *.c)
OBJ += $(patsubst %.c,$(OBJ_DIR)/%.o,$(wildcard *.c))

ASM += $(patsubst %.s,$(OBJ_DIR)/%.o,$(wildcard *.s))
ASM += $(patsubst %.S,$(ASMOBJ_DIR_DIR)/%.o,$(wildcard *.S))

#$(warning $(OBJ))

all: create_directories $(PROGRAM) iso

$(PROGRAM): $(OBJ) $(ASM)
	$(CC) -T linker.ld -o $@ $^ $(LDFLAGS)

$(OBJ_DIR)/%.o: %.cpp $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

$(OBJ_DIR)/%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

$(OBJ_DIR)/%.o: %.s
	$(AS) -o $@ $<

.PHONY: iso
iso: $(PROGRAM)
	@echo
	@./multiboot_test.sh
	@mkdir -p isodir/boot/grub
	@cp myos.bin isodir/boot/myos.bin
	@cp grub.cfg isodir/boot/grub/grub.cfg
	@grub-mkrescue -o myos.iso isodir

.PHONY: create_directories
create_directories: ${OBJ_DIR}
${OBJ_DIR}:
	${MKDIR_P} ${OBJ_DIR}

.PHONY: format
format: $(SRC) $(DEPS)
	astyle -n --indent=tab=4 $^

.PHONY: clean
clean:
	@echo
	rm -rf $(PROGRAM) $(OBJ) $(OBJ_DIR)
	rm -rf isodir
	@echo

#i686-elf-as boot.s -o boot.o
#i686-elf-gcc -c kernel.c -o kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
#i686-elf-gcc -T linker.ld -o myos.bin -ffreestanding -O2 -nostdlib boot.o kernel.o -lgcc
#./multiboot_test.sh

#mkdir -p isodir/boot/grub
#cp myos.bin isodir/boot/myos.bin
#cp grub.cfg isodir/boot/grub/grub.cfg
#grub-mkrescue -o myos.iso isodir
#
#qemu-system-i386 -cdrom myos.iso
#qemu-system-i386 -kernel myos.bin

