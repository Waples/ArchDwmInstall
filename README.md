# WARNING, THIS IS STILL WORK IN PROGRESS


## [WIP] Suckless Arch Install


### Info!
This script will install packages I use with my laptop and it will copy over my preferences from my [dotfiles](https://github.com/Waples/mydots)-repo and move them to the correct folders. It will also download, copy my config.h's and make some [suckless](https://suckless.org) tools (like  dwm, st and dmenu). 
My package installs will run through Pacaur, since it sources the pacman repo's aswell as the AUR, of which I have a few packages installed.

#### To Do:
- [ ] Add [jaagr]()'s dotfiles method in script
- [ ] Add ?
- [ ] Add ?
- [ ] Add ?
- [ ] Add ?
* [x] Remove *hardcoded* dotfiles & info from script.
* [x] Source all *user specifics* from a file.

#### How it works:
FIRST! Do not run this script as root; sudo with the user you want to create, or shit will get messy.

Now then:
1) Check if specified user exists. *(don't know if I will be changing this, bit redundant)*
1.2) ~~> remove EVERYTHING from that user's home directory
2) Update pacman packages.
3) Install script dependencies *(base-devel,git,expac,yajl)*.
4) Create my user directories.
5) Install pacaur.
6) Update pacaur (& pacman) packages.
7) Install packages specified in **pkg_list.txt** via pacaur.
8) Download my [dotfiles](https://github.com/Waples/mydots)-repo.
9) Download [suckless](https://suckless.org)-tools
10) Move configs to correct directories *(created in step 4)*.
11) Compile the suckless tools.
12) CLEANUP!
