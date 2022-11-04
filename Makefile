.PHONY: all
all: limos.iso

.PHONY: all-hdd
all-hdd: limos.hdd

.PHONY: run
run: limos.iso
	qemu-system-x86_64 -M q35 -m 2G -cdrom limos.iso -boot d

.PHONY: run-uefi
run-uefi: ovmf-x64 limos.iso
	qemu-system-x86_64 -M q35 -m 2G -bios ovmf-x64/OVMF.fd -cdrom limos.iso -boot d

.PHONY: run-hdd
run-hdd: limos.hdd
	qemu-system-x86_64 -M q35 -m 2G -hda limos.hdd

.PHONY: run-hdd-uefi
run-hdd-uefi: ovmf-x64 limos.hdd
	qemu-system-x86_64 -M q35 -m 2G -bios ovmf-x64/OVMF.fd -hda limos.hdd

ovmf-x64:
	mkdir -p ovmf-x64
	cd ovmf-x64 && curl -o OVMF-X64.zip https://efi.akeo.ie/OVMF/OVMF-X64.zip && 7z x OVMF-X64.zip

limine:
	git clone https://github.com/limine-bootloader/limine.git --branch=v4.x-branch-binary --depth=1
	make -C limine

.PHONY: kernel
kernel:
	$(MAKE) -C kernel

limos.iso: limine kernel
	rm -rf iso_root
	mkdir -p iso_root
	cp kernel/kernel.elf \
		limine.cfg limine/limine.sys limine/limine-cd.bin limine/limine-cd-efi.bin iso_root/
	xorriso -as mkisofs -b limine-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot limine-cd-efi.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		iso_root -o limos.iso
	limine/limine-deploy limos.iso
	rm -rf iso_root

limos.hdd: limine kernel
	rm -f limos.hdd
	dd if=/dev/zero bs=1M count=0 seek=64 of=limos.hdd
	parted -s limos.hdd mklabel gpt
	parted -s limos.hdd mkpart ESP fat32 2048s 100%
	parted -s limos.hdd set 1 esp on
	limine/limine-deploy limos.hdd
	sudo losetup -Pf --show limos.hdd >loopback_dev
	sudo mkfs.fat -F 32 `cat loopback_dev`p1
	mkdir -p img_mount
	sudo mount `cat loopback_dev`p1 img_mount
	sudo mkdir -p img_mount/EFI/BOOT
	sudo cp -v kernel/kernel.elf limine.cfg limine/limine.sys img_mount/
	sudo cp -v limine/BOOTX64.EFI img_mount/EFI/BOOT/
	sync
	sudo umount img_mount
	sudo losetup -d `cat loopback_dev`
	rm -rf loopback_dev img_mount

.PHONY: clean
clean:
	rm -rf iso_root limos.iso limos.hdd
	$(MAKE) -C kernel clean

.PHONY: distclean
distclean: clean
	rm -rf limine ovmf-x64
	$(MAKE) -C kernel distclean