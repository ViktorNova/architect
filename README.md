porteus-aur
===========

Port of the Arch Linux tools makepke, ABS, and AUR to build native .xzm packages for Porteus Linux/Slackware automatically utilizing the source repositories from Arch Linux and the Arch User Repository (AUR)

Do all this  as normal user!!! 

##Setup

1: Clone this repository, and activate all of the modules (you can skip the fakeroot module if you already have it)  
2: Uncomment a mirror in /etc/pacman.d/mirrorlist  
3: Sync entire ABS tree  

    $ abs

This will sync the entire tree of source PKGBUILDs from Arch Linux
into /var/abs/core, /var/abs/extra, and /var/abs/community (It only takes a few seconds).
Multib will fail to download for some reason and you'll see an error, but it's ok, everything else should be there

If you don't want the build scripts for everything, you can get just the ones you want by doing "abs repository/package", like this:    

    $ abs core/nano

This will download the PKGBUILD into /var/abs/core/nano

Now for the fun part:

##Choosing what package to build

First, go to the Arch Linux website and choose what package you want to build, from  
Arch  proper https://www.archlinux.org/packages   or
AUR  https://aur.archlinux.org/

To build the nano text editor from ABS, first change to the directory where the PKGBUILD is:

    $ cd /var/abs/core/nano

Change to that directory, then still as a normal user, do this:

    $ makepkg -d

Note: The -d flag is important here, it tells Arch's package manager not to try to resolve dependencies before downloading the source and building the package (which it will never find, because your system is full of Porteus modules, even if you have all the dependencies already)

This will automatically start downloading the source code, unpack it, compile it, patch it (if the PKGBUILD contains any patches) and package it up into an Arch package! (assuming there are no errors, which are usually only due to a missing library/dependency found during the congigure part.) If there are missing libraries or build dependencies, you will usually be toldwhat they are. You will need to install those dependencies from Porteus Package Manager or build them using this method and install them first before continuing. 

##Creating a Porteus module
Once abs reports that it has build your package successfully, the next step is to make a Porteus module, since we can't use the .tar.xz Arch package it made. I know there's got to be an easy way to have makepkg make an xzm package instead, but I haven't figured it out yet (anybody know how? I suspect it might involve a modified dir2xzm?), so there's a few extra small steps:  

1: Change to the newly created directory "pkg"
2: Make a porteus module using "dir2zm pkgname pkgname-pkgversion.xzm" Example:  

    $ cd pkg
    $ dir2xzm nano nano-2.2.6-2-x86_64.pkg.xzm

This will prompt for root password, and create a Porteus module in the current directory. 

I like to just copy the filename from the generated Arch package and use this as the name for the Porteus module, since it has the exact version in it. I also personally like to leave the .pkg on there before the .xzm so that I always know at a glance which modules are from Arch, but name it whatever you like. Note that you can also do 
'fakeroot dir2xzm nano nano-2.2.6-2-x86_64.pkg.xzm' and you will not be prompted for a root password.

That's it! Activate your new package or put it in your modules directory

##Building from AUR
If the package is in AUR, it's even easier! =D 

    aur.sh -d nano-syntax-highlighting-git
    
(note the -d flag as before)
This will download create a folder called nano-syntax-highlighting-git in your current directory, download the PKGBUILD into it, and begin the process above, just as if you had run 'makepkg -d'. When the package is finished compiling, use the above steps to create a Porteus module

Note: Occasionally, the PKGBUILD contains patches or commands that are not compatible with Porteus/Slackware, but can be fixed very easily. If the package fails to build for some weird reason, look at the PKGBUILD to see if you notice anything. For instance, Arch packages that use QT and qmake tend to use the command 'qmake-qt4' instead of 'qmake', as Porteus/Slackware uses currently. In this case, you can modify the PKGBUILD, or you can just do this
 
    ln -s /usr/bin/qmake /usr/bin/qmake-qt4

Also, if you modify the PKGBUILD and then get an error that something failed the integrity check, you will need to run makepkg like this:

    makepkg -d --skipinteg
    
Finally, you MUST run makepkg as a normal user! For safety, but moreso because Slackware also has a program called makepkg, which is used to build Slackware packages, but it lives in /sbin/makepkg (outside normal user's default path) whereas Arch's makepkg lives in /usr/bin. Basically, if you run it as root, it won't work. If you happen to have /sbin in your normal user's path, you will need to run this as /usr/bin/makepkg


Right now I just have the xzm modules up here, but this will soon become a real source repository. All Arch-related modules are directly converted from official Arch 64-bit packages and were not modified by me at all.   

aur.sh was taken from here https://wiki.archlinux.org/index.php/Aur.sh and made into an xzm module  

Please feel free to contribute ideas and issues, submit pull requests, or correct me on any of my terminology ;)
