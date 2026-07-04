### AnyKernel3 Ramdisk Mod Script
## KernelSU-Next for realme GT Neo (RMX3031)

### AnyKernel setup
properties() { '
kernel.string=KernelSU-Next for realme GT Neo (RMX3031)
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=RMX3031
device.name2=RMX3031CN
device.name3=realme GT Neo
device.name4=GT Neo
supported.versions=11
'; } # end properties

### AnyKernel install
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
BLOCK=auto;
IS_SLOT_DEVICE=0;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;
kernel=Image.gz-dtb;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
dump_boot;
write_boot;
## end boot install
