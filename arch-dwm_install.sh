#!/bin/bash

#     INFO
echo -ne "\nArch Linux with a bit of Suckless\n2018 - Waples\nVersion: 0.4\n"

#     INCLUDES
. user_configs.txt

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
pkg_update="pacman -Syu --noconfirm"
pkg_cmd="pacman -Sy --noconfirm --needed"
aur_update="pacaur -Syu --noconfirm"
aur_cmd="pacaur -Sy --noconfirm --needed"

your_dotfiles="https://github.com/Waples/mydots.git"   # my dotfiles
git_list=$(cat git_list.txt)                    # github scripts / tools :D
sck_list=$(cat sck_list.txt)                    # suckless github pckgs
pkg_list=$(cat pkg_list.txt)                    # Arch & Aur packages


#     CHECKS
user_exist=$(id -u $main_user > /dev/null 2>&1; echo $?)
if [ "$user_exist" == "0" ]; then
  echo -ne "User $main_user found on system.\nClearing out $loc_home.\nContinue ...\n"
  rm -r $loc_home/*
else
  echo -ne "User $main_user doesn't exist yet.\nAdd him...\nExiting ...\n"
  exit
fi


#     DEPENDENCIES
echo -ne "\nUpdating system ...\n"
$pkg_update
echo -ne "\nInstalling dependencies ...\n"
$pkg_cmd base-devel
$pkg_cmd git expac yajl

#     DIRECTORIES AND LOCALS
mkdir -p $loc_home/.local/{tmp,share,var,backup,bin,suckless}
mkdir -p $loc_home/{builds,ebooks,projects,media,github,downloads,documents,stackstorage,torrents}

#     PACAUR INSTALL
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
cd $loc_home
$aur_update
for pkg in $pkg_list; do
  $aur_cmd $pkg
done

#     DOTFILES DOWNLOAD     
cd $loc_tmp
rm $loc_tmp/*
$git_cmd $your_dotfiles
cd $(ls)
mv {.aliases,.bashrc,.bash_profile,.config,.functions,.vimrc,.xinitrc} $loc_home
echo -ne "Dotfiles downloaded\nMoved some configs to $loc_home\nSuckless remains in $((ls $loc_tmp))"

#     SUCKLESS INSTALL     
cd $loc_suck
for suckless in $sck_list; do
  $git_cmd $suckless
done
echo "Downloaded suckless tools"

echo "Moving dotfiles config.mk && config.h's to suckless"
mv $loc_tmp/mydots/.local/suckless/dwm/* $loc_suck/dwm/
mv $loc_tmp/mydots/.local/suckless/dmenu/* $loc_suck/dmenu/
mv $loc_tmp/mydots/.local/suckless/st/* $loc_suck/st/

for suck_install in $(ls); do
  cd $suck_install
  make clean install
  cd $loc_suck
done

#     GITHUB scripts install
cd $loc_tmp
rm $loc_tmp/*
for gits in $git_list; do
  $git_cmd $gits
done

#     SETUP `mydots`-method, as described by jaagr
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
pacman -Syu --noconfirm && pacman -Sc --noconfirm && reboot

# vim:ft=sh
