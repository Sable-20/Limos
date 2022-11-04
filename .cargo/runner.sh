#!/bin/sh

# executes with cargo run

set -xe

LIMINE_GIT_URL="https://github.com/limine-bootloader/limine.git"

KERNEL=$1

# clone repo if we dont have git
if [ ! -d target/limine ]; then
  git clone $LIMINE_GIT_URL --depth=1 --branch v3.0-branch-binary target/limine
fi

cd target/limine
git fetch
make
cd -

# Copy the needed files into an ISO image.
mkdir -p target/iso_root
cp $KERNEL conf/limine.cfg target/limine/limine{.sys,-cd.bin,-cd-efi.bin} target/iso_root

xorriso -as mkisofs                                             \
    -b limine-cd.bin                                            \
    -no-emul-boot -boot-load-size 4 -boot-info-table            \
    --efi-boot limine-cd-efi.bin                                \
    -efi-boot-part --efi-boot-image --protective-msdos-label    \
    target/iso_root -o $KERNEL.iso

# For the image to be bootable on BIOS systems, we must run `limine-deploy` on it.
target/limine/limine-deploy $KERNEL.iso

# Run the created image with QEMU.
qemu-system-x86_64 \
    -machine q35 -cpu qemu64 -M smm=off \
    -D target/log.txt -d int,guest_errors -no-reboot -no-shutdown \
    -serial stdio \
    $KERNEL.iso