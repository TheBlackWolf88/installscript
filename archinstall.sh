#!/bin/bash
echo "Hey, I'm gonna ask you a few questions. First, what keyboard layout you wanna use?"
read kblayout
echo Layout: $kblayout
loadkeys $kblayout 
timedatectl set-ntp true
echo "Hey, hey, it's time for the second question, what disk are you installing on? "
read diskdev
wipefs -a $diskdev
echo "What partition table you wanna use? (DOS/GPT)"
read parttabledata
parttable="${parttabledata,,}"
echo "How large you want your swap? (General rule: <1G -> same as ram; >1G -> half of ram)"
read swapsize
if [ $parttable = "gpt" ]
then
    (
        echo g;
        echo n;
        echo ;
        echo ;
        echo +512M;
        echo ;
        echo n;
        echo ;
        echo ;
        echo +$swapsize"G"
        echo n;
        echo ;
        echo ;
        echo ;
        echo ;
        echo t;
        echo 1;
        echo 1;
        echo t;
        echo 2;
        echo 19;
        echo w;
    ) | fdisk $diskdev
elif [ $parttable = "dos" ]
then
    (
        echo o;
        echo n;
        echo ;
        echo ;
        echo ;
        echo -$swapsize"G"
        echo ;
        echo n;
        echo ;
        echo ;
        echo ;
        echo ;
        echo t;
        echo 2;
        echo 19;
        echo w;
    ) | fdisk $diskdev
else
    echo "Only DOS and GPT is supported ATM, the program will exit."
    break
fi

read -p "What do you want for your filesystem? (ext4/btrfs/any other shit just spell it right)" fs
mkswap $diskdev"2"
if [ $parttable = gpt ]
then
    mkfs.vfat $diskdev"1"
    mkfs.$fs $diskdev"3"
    mkdir /mnt/boot
    mount $diskdev"3" /mnt
    mount $diskdev"1" /mnt/boot
    bootloader="grub efibootmgr"
else 
    mkfs.$fs $diskdev"1"
    mount $diskdev"1" /mnt
    bootloader="grub"
fi
swapon $diskdev"2"

read -p "What editor you wanna install? (package name)" editor
read -p "What terminal emulator you wanna install? (package name)" terminal
read -p "What browser you wanna install? (package name)" browser
read -p "Intel or AMD?" ucode
ucode=${ucode,,}"-ucode"

pacstrap /mnt base linux linux-firmware $editor $terminal $browser libxinerama xorg-server xorg-server-common xorg-setxkbmap xorg-xauth xorg-xinit xorg-xkill xorg-xmodmap xorg-xrdb base-devel git networkmanager $ucode $bootloader ranger dunst neofetch feh picom

genfstab -U /mnt >> /mnt/etc/fstab
cp /root/installscript/archinstall2.sh /mnt/archvol2.sh
arch-chroot /mnt sh archvol2.sh




