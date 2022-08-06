# 🌊 SplashOS - The modern Linux Distro for Normies
**⚠️ THIS IS IN EARLY DEVELOPMENT AND NOT READY FOR ANY RELEASE BUILDS ⚠️**

SplashOS is a modern Linux Distro aims to be as easy as possible for non technical users.

## 1️⃣ Preparing the build enviroment 
Please note: these steps are for advanced users only.

Follow these steps to build the distro.
It is recommanded to do this in a virtual machine. The automatic scripts will make a new user called `distbuild` and is required as a safety user to prevent nuking your system when something goes wrong.

First let's get the repo and get into the build enviroment directory:
```sh
mkdir -p ~/Documents/GitHub && cd ~/Documents/GitHub
git clone https://github.com/MVDW-Java/SplashOS.git
cd SplashOS/build_env
```
Make sure all the files is in `~/Documents/GitHub/SplashOS` as the paths are hard coded for now but we will clean the scripts up soon.
Before we do anything let's check that all the packages is installed.
```sh
./version_check.sh
```
it should look something like this:
```
bash, version 5.1.4(1)-release
/bin/sh -> /usr/bin/bash
Binutils: (GNU Binutils for Debian) 2.35.2
bison (GNU Bison) 3.7.5
/usr/bin/yacc -> /usr/bin/bison.yacc
Coreutils:  8.32
diff (GNU diffutils) 3.7
find (GNU findutils) 4.8.0
GNU Awk 5.1.0, API: 3.0 (GNU MPFR 4.1.0, GNU MP 6.2.1)
/usr/bin/awk -> /usr/bin/gawk
gcc (Debian 10.2.1-6) 10.2.1 20210110
g++ (Debian 10.2.1-6) 10.2.1 20210110
grep (GNU grep) 3.6
gzip 1.10
Linux version 5.10.0-16-amd64 (debian-kernel@lists.debian.org) (gcc-10 (Debian 10.2.1-6) 10.2.1 20210110, GNU ld (GNU Binutils for Debian) 2.35.2) #1 SMP Debian 5.10.127-1 (2022-06-30)
m4 (GNU M4) 1.4.18
GNU Make 4.3
GNU patch 2.7.6
Perl version='5.32.1';
Python 3.9.2
sed (GNU sed) 4.7
tar (GNU tar) 1.34
texi2any (GNU texinfo) 6.7
xz (XZ Utils) 5.2.5
g++ compilation OK
```
If there is a package not installed please install in using your package manager.

Now we need to get into root for the step after this one, creating the environment variables.

(replace [user] with the username from the user that has the files)
```sh
sudo su -
source ./quick_env_export.sh [user]
```

We can now start the prepare script that will create the `build_root`, download all required files, and make a new user called `distbuild` if it's not there.
```sh
./prepare.sh
```

The last step for the preperation is to switch the new user the script created.

```sh
su distbuild
```

## 2️⃣ Creating the distro

Because this distro is far from finished, the creation script will only compile and configure the required tools needed.
In the previous step, when we prepared we switched to `distbuild`, so environment variables are lost.

```sh
source ./quick_env_export.sh [user]
```
Now we will finally create the distro
```sh
./create.sh
```

Thats it for now, this will be expanded when this project comes farther in development.

## 🙏 Special thanks to
[LFS](https://www.linuxfromscratch.org/lfs/) - For all the great documentation

[Low Level Devel](https://www.youtube.com/channel/UCRWXAQsN5S3FPDHY4Ttq1Xg) - To help me understand more and provide the scripts needed to make this.
