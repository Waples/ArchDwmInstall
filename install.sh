#!/bin/bash

#     INFO
echo -e "\n
Arch Linux with a bit of Suckless
2018 - Waples\nVersion: 0.7\n
This snippet uses sudo commands in the scripting.
DO NOT RUN THIS AS ROOT and DO NOT USE '$ sudo arch-dwm_install.sh' !
Add your user to the sudo/wheel group(s) instead, it will prompt you for passwords when needed.
\n"

#     INCLUDES
. configs
. messages

#     VARIABLES
loc_home="/home/$main_user"
loc="$loc_home/.local"
loc_bin="$loc/bin"
loc_share="$loc/share"
loc_var="$loc/var"
loc_tmp="$loc/tmp"
loc_backup="$loc/backup"
loc_suck="$loc/suckless"

git_cmd="git clone"
pkg_update="sudo pacman -Syu --noconfirm"
pkg_cmd="sudo pacman -Sy --noconfirm --needed"
aur_update="sudo pacaur -Syu --noconfirm"
aur_cmd="sudo pacaur -Sy --noconfirm --needed"

git_list=$(cat github)                    # github scripts / tools :D
sck_list=$(cat suckless)                  # suckless github pckgs
pkg_list=$(cat packages)                  # Arch & Aur packages


#     CHECKS
    ## check if running as sudo
whatlvl=$(echo $UID)
case $whatlvl in
  0)
    echo -e " YE SHALL NOT PASS, ye be using sudo or root! \n"
    exit
  ;;
  [1-9]000)
    echo -e " No sudo or root detected, continue! \n"
  ;;
esac
    ## check if user has been created.
user_exist=$(id -u $main_user > /dev/null 2>&1; echo $?)
if [ "$user_exist" == "0" ]; then
  echo -ne " User $main_user found on system.\nClearing out $loc_home.\nClearing home directory ...\n"
  rm -r $loc_home/*
else
  echo -ne " User $main_user doesn't exist yet.\nCreate user with UID 1000\nExiting ...\n"
  exit
fi


#     DEPENDENCIES
$bird $msg_update
$pkg_update
$bird $msg_depend
$pkg_cmd base-devel
$pkg_cmd git expac yajl

#     DIRECTORIES AND LOCALS
$bird $msg_dirs
mkdir -p $loc_home/.local/{tmp,share,var,backup,bin,suckless}
mkdir -p $loc_home/{builds,documents,downloads,ebooks,games,github,media,projects,stackstorage,torrents,vms}

#     PACAUR INSTALL
$bird $msg_aur
cd $loc_tmp
mkdir pacaur_install
if [ ! -n "$(pacman -Qs cower)" ]; then
  curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
  makepkg PKGBUILD --skippgpcheck --install --needed
fi
if [ ! -n "$(pacman -Qs pacaur)" ]; then
  curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
  makepkg PKGBUILD --install --needed
fi

#     PKG INSTALL (with PACAUR)
$bird $msg_aurupdate
cd $loc_home
$aur_update
for pkg in $pkg_list; do
  $aur_cmd $pkg
done

#     DOTFILES DOWNLOAD
$bird $msg_dotfiles
cd $loc_tmp
rm $loc_tmp/*
$git_cmd $your_dotfiles
cd $(ls)
mv {.aliases,.bashrc,.bash_profile,.config,.functions,.vimrc,.xinitrc} $loc_home
echo -ne "Dotfiles downloaded\nMoved some configs to $loc_home\nSuckless remains in $((ls $loc_tmp))"

#     SUCKLESS INSTALL     
$bird $msg_suck
cd $loc_suck
for suckless in $sck_list; do
  $git_cmd $suckless
done

echo "Moving dotfiles config.mk && config.h's to suckless"
mv $loc_tmp/mydots/.local/suckless/dwm/* $loc_suck/dwm/
mv $loc_tmp/mydots/.local/suckless/dmenu/* $loc_suck/dmenu/
mv $loc_tmp/mydots/.local/suckless/st/* $loc_suck/st/

$bird $msg_build
for suck_install in $(ls); do
  cd $suck_install
  make clean install
  cd $loc_suck
done

#     GITHUB scripts install
$bird $msg_git
cd $loc_tmp
rm $loc_tmp/*
for gits in $git_list; do
  $git_cmd $gits
done

#     SETUP `mydots`-method, as described by jaagr
$bird $msg_mydots
cd $loc_home
git init --bare $loc_home/.mydots.git
git remote add origin $your_dotfiles
git config status.showUntrackedFiles no
git config alias.untracked "status -u"
git config alias.untracked-at "status -u"
git config alias.update "add --update"
git config alias.commit "commit -m"
echo "alias dots='git --git-dir=$HOME/.mydots.git/ --work-tree=$HOME'" >> $loc_home/.aliases

#     CLEANUP & UPDATE
rm -r $loc_tmp/*
sudo pacman -Syu --noconfirm && sudo pacman -Sc --noconfirm
clear; echo -e "\n\n\n  If you got this far, this shit actually worked!   \n\n\n   Restarting!\n\n ..."
systemctl reboot

# vim:ft=sh
