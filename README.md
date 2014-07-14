A short collection of recipes for odroid [xu](http://www.hardkernel.com/main/products/prdt_info.php?g_code=G137510300620)/[xu lite](http://www.hardkernel.com/main/products/prdt_info.php?g_code=G138503207322).
When available, a link to some documentation/forum thread is provided at the beginning of each recipe. Please refer to those references in case of trouble.

## Prerequisites

Those scripts were tested using the [ubuntu_server-14.04lts-armhf-ODROID-XU-20140604.img](http://odroid.in/ubuntu_14.04lts/ubuntu_server-14.04lts-armhf-ODROID-XU-20140604.img.xz) image. The purpose of provided scripts is to make it easier to setup/test some installations with an ubuntu system. It should be easy to extend this to work with other Linux distros.

You'll likely need some space on your system so you may first take a look at [odroid utility](https://github.com/mdrjr/odroid-utility) (that may already be on your system at `/usr/local/bin/odroid-utility.sh`).
**No warranty provided so use with care.**

## Philosophy

The `foo.sh` script should provide a way to install the `foo` library on the odroid xu.
To install `foo`, source the `foo.sh` script (e.g. by executing `. foo.sh` in a terminal) and call `build_foo`. For some libraries, some arguments might be required; their use should be obvious from the code (and when possible a default value is provided). A `test_libfoo` function should be provided to test that everything went well (and validate dependencies in some cases).
The scripts should be run as the `root` user (at least from a sudoer account).

Note that you may specify where you want to clone git repositories by exporting a `CLONE_DIR` variable which defaults to `/root/builds`.

## Links

* http://forum.odroid.com/viewforum.php?f=59
* http://odroid.com/dokuwiki/doku.php?id=en:odroid-xu
