![SplashOS Logo](https://raw.githubusercontent.com/MVDW-Java/SplashOS/main/assets/logo.png)
# 🌊 SplashOS - The easy to use modern Linux Distro

SplashOS is a modern Linux Distro aims to be as easy as possible for non technical users.

## 🏗️ Building Splash from source 
Please note: these steps are for advanced users only.

Follow these steps to build the distro.
It is recommanded to do this in a virtual machine. The automatic scripts will make a new user called `splashbuilder` and is required as a safety user to prevent nuking your system when something goes wrong.

First let's get the repo and get into the build enviroment directory:
```sh
git clone https://github.com/MVDW-Java/SplashOS.git
```
```sh
cd SplashOS/build_env
```

Now lets prepare your host system and download all packages required for building SplashOS.
Its recommended to make a seperate partition or use another drive where SplashOS can be build on for directly booting from it.

⚠️ **Note:** *This script will ask you some questions and is not fully automatic, after this step it won't interrupt you for other questions*
```sh
./prepare_splashos.sh
```

After preparing the build enviroment its required to change user as splashbuilder, this is to prevent breaking your host system.
Skipping this step will not work as it will give an error in the build_splash.sh script
```sh
su splashbuilder
```

Now that you changed the user as splashbuilder we can finally build the first part of SplashOS.
```sh
./build_splashos.sh
```

After being building some basic tools we can now chroot into the enviroment.
Everything you do in this enviroment won't affect your host system.
```sh
./chroot_splashos.sh
```

Before we can continue building we need to prepare some basic stuff in the chroot enviroment.
```sh
./prepare_chroot.sh
```

Now we can continue building into the chroot enviroment, this is split into 2 steps to allow the new bash to be running that is build in step 1.
```sh
./build_part1_chroot.sh
```
```sh
./build_part2_chroot.sh
```

🎉 You have now fully build SplashOS.



## 🙏 Special thanks to
[LFS](https://www.linuxfromscratch.org/lfs/) - For all the great documentation

[Low Level Devel](https://www.youtube.com/channel/UCRWXAQsN5S3FPDHY4Ttq1Xg) - To help me understand more and provide the scripts needed to make this.

[jasperes](https://github.com/jasperes) - For the bash YAML parser.
