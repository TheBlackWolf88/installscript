#!/bin/bash

read -p "Where are you? (Zone/City)" time
ln -sf /usr/share/zoneinfo/$time /etc/localtime
hwclock --systohc
echo "I'm gonna generate the en_US.UTF-8 locale, if you need others read the archwiki and add them at the end."
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=hu" > /etc/vconsole.conf
read -p "Gimme a hostname" hostname
echo $hostname > /etc/hostname
mkinitcpio -P
passwd
read -p "We're creating a user for you, what's your name?" uname
useradd -m -G wheel $uname
echo "We're gonna need a passwd for $uname"
passwd $uname

x=`pacman -Qs efibootmgr`
if [ -n "$x" ]
then grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else 
    read -p "Sorry for the inconvinience, but I forgot, what's your disk, that you're installing on, tell me again!" dev
    grub-install --target=i386-pc $dev
fi

grub-mkconfig -o /boot/grub/grub.cfg
read -p "You wanna use dan's DWM setup? (y/N)" dwm
if [ $dwm='y' ]
then
    git clone https://github.com/TheBlackWolf88/dotfiles-dwm /home/$uname
    mkdir -p /home/$uname/.config
    cd /home/$uname/dotfiles-dwm
    cp -rt /home/$uname/.config alacritty dunst dwm dwmbar neofetch ranger picom.conf
    cp wall.jpg /home/$uname/.wall.jpg
    cp /home/$uname/ .bashrc .xinitrc
    cp startdwm /bin/startdwm
    cd /home/$uname/.config/dwm
    make
    make clean install
    echo "You installed dan's dwm setup, reboot and after login type 'startx'"
else
    echo "You do you"
fi
echo "Installation finished. Exit chroot with 'exit', and 'reboot' your machine with 'reboot'"
