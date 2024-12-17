nasm gianinterp.asm -fbin -o gi.bin
nasm padding.asm -fbin -o pd.bin
cat gi.bin test.gian pd.bin > disk.dd
qemu-system-x86_64 -hdd disk.dd -monitor stdio