#!/bin/bash

PKGTYPE="deb"
#PKGTYPE="tar"  # Pick this for Slackware
#PKGTYPE="solaris"

PKGEXT=$PKGTYPE # TODO - make this work for "tar" and "solaris" (only works for deb/rpm at the moment)

echo "Thingy to automate building packages from source code that uses cmake"
echo "By Viktor Nova"
ls -l --color=auto
echo
mkdir build
cd build
echo "Yo. Before compiling the thing, should I:"
echo " "
echo "1: Clean the build directory"
echo "2: Wipe it out"

read -p "(Default: neither) ? " c
case $c in
    1)	echo "Cleaning.."
	make clean
	make distclean;;
    2) 	echo "Removing everything from build directory.."
	rm -rf ./*;;
    *)  echo "Leaving build dir intact";;
esac

echo "TODO: make a prompt for DCMAKE_PREFIX"
echo "Running cmake.."
cmake .. && make -j4 && echo "BUILD SUCCESSFUL" 
ls -l --color=auto

echo 
cd ..

read -p "What is the package name? (${PWD##*/})" PKGNAME
if [ -z "$PKGNAME" ]; then
	PKGNAME=${PWD##*/}
fi

cd build
mkdir -p pkg/$PKGNAME

make DESTDIR=`pwd`/pkg/$PKGNAME/ install 




read -p "What is the version? " PKGVERSION

echo
echo 	"0: System default"
echo 	"1: All (noarch)"
echo 	"2: i386"
echo 	"3: i686"
echo 	"4: x86_64"
echo 	"5: Other (specify) \n"

read -p "What is the architecture? (0) " n
case $n in
    0) ARCHITECTURE="native";;
    1) ARCHITECTURE="all";;
    2) ARCHITECTURE="i386";;
    3) ARCHITECTURE="i686";;
    4) ARCHITECTURE="x86_64";;
    5) read -p "Enter your target package architecture: " ARCHITECTURE;;
    *) 	echo "Invalid choice. Building default system native package"
	ARCHITECTURE="native";;
esac

if [ -d "pkg/$PKGNAME" ]; then
	pushd pkg/$PKGNAME
	echo "Stripping binaries"
	find . | xargs file | grep ELF | cut -f 1 -d : | xargs strip --strip-unneeded
	ls -l --color=auto
	popd
	echo "Creating $ARCHITECTURE package with FPM"
	fpm -s dir -t $PKGTYPE -n $PKGNAME -v $PKGVERSION -p $PKGNAME-VERSION_ARCH.$PKGEXT -a $ARCHITECTURE -C pkg/$PKGNAME/ . && \
		echo -e "Righteous dude, your package has been created.\n"  \
		mv *.$PKGTYPE ..
		echo "Listing packages in current directory: \n" \
		ls --color=auto *.$PKGTYPE \ 
		exit 0
	echo "there mighta been a problem with FPM"
	exit 1
fi

echo "Error, dude. The directory pkg/$PKGNAME don't exist yo."
exit 1

#cd pkg/$PKGNAME && \
#rm -f .MTREE .PKGINFO && \
#fpm -s dir -t deb -n $PKGNAME -v $VERSION . && \ 
#cd ../..
#echo -e "Righteous, $PKGTYPE package has been created.\n" && \
#ls --color *.deb

# ----------------------------------
# FPM takes the argument "--depends DEPENDENCY", and it can be declared multiple times
# 

# Arch's makepkg generates a .PKGINFO file that has lines like this:
# depend = pcre
# depend = libgl
# ..etc, so it would be easy to use awk to parse that into a legitimate argument to do it



# THIS DOESN'T WORK YET BUT HERE'S THE SYNTAX
# fpm -t deb -s dir -n $PKGNAME -v $VERSION $DIR
