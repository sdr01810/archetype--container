#!/bin/sh sourced
##

set -e

os_release_ID="$(os_release ID)"

os_release_ARCH="$(os_release ARCH)"

os_release_VERSION_ID="$(os_release VERSION_ID)"

os_release_VERSION_ID_major="${os_release_VERSION_ID%.*}"

##

should_list_packages_needed_only_in_testing_environment=false

should_list_packages_needed_only_in_production_environment=false

##

if false ; then :
elif [ "${os_release_ID:?}" = ubuntu -a "${os_release_VERSION_ID_major:?}" -ge 20 ] ; then

	should_install_apt_package_cuda_toolkit=true ; cuda_toolkit_version=10.1

	gcc_version=7 # min supported by Ubuntu
	gcc_version=9 # max supported by Ubuntu
	gcc_version=8 # max supported by Ubuntu + CUDA
	gcc_version=8 # max supported by Ubuntu + CUDA + Boost

elif [ "${os_release_ID:?}" = ubuntu -a "${os_release_VERSION_ID_major:?}" -ge 18 ] ; then

	should_install_apt_package_cuda_toolkit=true ; cuda_toolkit_version=9.1

	gcc_version=5 # min supported by Ubuntu
	gcc_version=8 # max supported by Ubuntu
	gcc_version=6 # max supported by Ubuntu + CUDA
	gcc_version=6 # max supported by Ubuntu + CUDA + Boost(?)

elif [ "${os_release_ID:?}" = ubuntu -a "${os_release_VERSION_ID_major:?}" -ge 16 ] ; then

	should_install_apt_package_cuda_toolkit=false ; cuda_toolkit_version=

	gcc_version=5 # min supported by Ubuntu
	gcc_version=5 # max supported by Ubuntu
	gcc_version=5 # max supported by Ubuntu + CUDA
	gcc_version=5 # max supported by Ubuntu + CUDA + Boost
else
	should_install_apt_package_cuda_toolkit=false ; cuda_toolkit_version=

	gcc_version=
fi

##

python2_markdown_version='==3.1.1' # last version to support python 2.7

case "${os_release_ID:?}-${os_release_VERSION_ID:?}" in
ubuntu-16.04)
	boost_version=1.58.0
	boost_dev_version=${boost_version%.*}

	jpeg_turbo_version=8

	log4cxx_version=10v5
	log4cxx_dev_version=10

	ncurses_version=5

	nss_version=3

	opencv_version=2.4v5

	pcre_version=3

	python3_lxml_version='==3.7.3'

	tiff_version=5

	xml_version=2
	xslt_version=1
	;;

ubuntu-18.04)
	boost_version=1.62.0
	boost_version=1.65.1
	boost_dev_version=${boost_version%.*}

	jpeg_turbo_version=8

	log4cxx_version=10v5
	log4cxx_dev_version=

	ncurses_version=5

	nss_version=3

	opencv_version=3.2

	pcre_version=3

	python3_lxml_version=

	tiff_version=5

	xml_version=2
	xslt_version=1
	;;

ubuntu-20.04)
	boost_version=1.71.0
	boost_dev_version=${boost_version%.*}

	jpeg_turbo_version=8

	log4cxx_version=10v5
	log4cxx_dev_version=

	ncurses_version=5

	nss_version=3

	opencv_version=4.2

	pcre_version=3

	python3_lxml_version=

	tiff_version=5

	xml_version=2
	xslt_version=1
	;;

*|'')
	echo 1>&2 "Unrecognized OS release: ${os_release_ID:?}-${os_release_VERSION_ID:?}"
	return 2
	;;
esac

##

cat <<-END

	##
	## Basic networking tools:
	##

	inetutils-traceroute
	iputils-ping
	iputils-tracepath

	##
	## For building typical C/C++ source code:
	##

	build-essential
	autoconf
	ccache

	make
	unzip

	libboost${boost_dev_version}-all-dev
	libboost-chrono${boost_version}
	libboost-date-time${boost_version}
	libboost-filesystem${boost_version}
	libboost-program-options${boost_version}
	libboost-regex${boost_version}
	libboost-serialization${boost_version}
	libboost-system${boost_version}
	libboost-thread${boost_version}
	libboost-timer${boost_version}

	libjpeg-turbo${jpeg_turbo_version}-dev
	libjpeg-turbo${jpeg_turbo_version}

	liblog4cxx${log4cxx_dev_version}-dev
	liblog4cxx${log4cxx_version}

	libncurses${ncurses_version}-dev

	libnss${nss_version}-tools

	libopencv-dev
	libopencv-contrib${opencv_version}
	libopencv-core${opencv_version}
	libopencv-highgui${opencv_version}
	libopencv-imgproc${opencv_version}

	libpcre${pcre_version}-dev

	libssl-dev

	libtiff${tiff_version}-dev
	libtiff${tiff_version}

	libxml${xml_version}-dev

	libxslt${xslt_version}-dev

	libzip-dev

	##
	## CMake:
	##

	apt-key:  url https://apt.kitware.com/keys/kitware-archive-latest.asc
	apt-repo: deb https://apt.kitware.com/\$(os_release ID) \$(os_release VERSION_CODENAME) main

	cmake
	cmake-curses-gui
	cmake-doc

	##
	## Python:
	##

	python2::

	python2:asyncio
	python2:markdown${python2_markdown_version}

	python3::

	python3:asyncio
	python3:markdown

	python3:lxml${python3_lxml_version}
	python3:matplotlib
	python3:numpy
	python3:requests
	python3:scipy
END

##

! "${should_install_apt_package_cuda_toolkit:?}" ||

cat <<-END

	nvidia-cuda-toolkit
END

##

! "${should_list_packages_needed_only_in_testing_environment:?}" ||

cat <<-END

	binutils-dev
	checkinstall
	cheese
	chromium-browser
	cifs-utils
	curl
	dconf-tools
	emacs
	exfat-fuse
	exfat-utils
	gimp
	git
	hexchat
	meld
	mousepad
	nmon
	openocd
	openssh-server
	p7zip-full
	sqlitebrowser
	unzip
	valgrind
	vim
	vlc

	catch
	dicom3tools
	git-cola
	ipython3
	libiberty-dev
	libimlib2-dev
	libreadline-dev
	libxslt-dev
	libzmq3-dev
	locate

	bison
	dconf-editor
	e2fsprogs
	filezilla
	flex
	htop
	tmux
	tree
END

##

! "${should_list_packages_needed_only_in_production_environment:?}" ||

cat <<-END

	openssh-server

	apt:options=( --no-install-recommends ):xorg
	apt:options=( --no-install-recommends ):dkms
	apt:options=( --no-install-recommends ):pulseaudio
	apt:options=( --no-install-recommends ):fonts-noto-cjk
	apt:options=( --no-install-recommends ):chromium-browser
END

##

! [ -n "${gcc_version}" ] ||

cat <<-END

	gcc-${gcc_version:?}
	g++-${gcc_version:?}

	update-alternatives: --install /usr/bin/gcc gcc /usr/bin/gcc-${gcc_version:?} 10000
	update-alternatives: --set                  gcc /usr/bin/gcc-${gcc_version:?}

	update-alternatives: --install /usr/bin/g++ g++ /usr/bin/g++-${gcc_version:?} 10000
	update-alternatives: --set                  g++ /usr/bin/g++-${gcc_version:?}
END

##

