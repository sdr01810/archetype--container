:

set -e

os_release_ID="$(os_release ID)"

os_release_VERSION_ID="$(os_release VERSION_ID)"

os_release_VERSION_ID_major="${os_release_VERSION_ID%.*}"

##

cmake_os_release_VERSION_CODENAME=

emacs_os_release_VERSION_CODENAME=

p4_os_release_VERSION_CODENAME=

if [ "${os_release_ID}" != ubuntu ] ; then

	:

elif [ "${os_release_VERSION_ID_major:?}" -ge 20 ] ; then

	cmake_os_release_VERSION_CODENAME=focal

	emacs_os_release_VERSION_CODENAME=focal

	p4_os_release_VERSION_CODENAME=focal

	if [ "${os_release_VERSION_CODENAME}" != focal ] ; then

		emacs_os_release_VERSION_CODENAME=
	fi

elif [ "${os_release_VERSION_ID_major:?}" -ge 18 ] ; then

	cmake_os_release_VERSION_CODENAME=bionic

	emacs_os_release_VERSION_CODENAME=bionic

	p4_os_release_VERSION_CODENAME=bionic

elif [ "${os_release_VERSION_ID_major:?}" -ge 16 ] ; then

	cmake_os_release_VERSION_CODENAME=xenial

	emacs_os_release_VERSION_CODENAME=xenial

	p4_os_release_VERSION_CODENAME=xenial

elif [ "${os_release_VERSION_ID_major:?}" -ge 14 ] ; then

	cmake_os_release_VERSION_CODENAME=

	emacs_os_release_VERSION_CODENAME=trusty

	p4_os_release_VERSION_CODENAME=trusty

elif [ "${os_release_VERSION_ID_major:?}" -ge 12 ] ; then

	cmake_os_release_VERSION_CODENAME=

	emacs_os_release_VERSION_CODENAME=precise

	p4_os_release_VERSION_CODENAME=precise
fi

##

[ -z "${cmake_os_release_VERSION_CODENAME}" ] ||

cat <<-END

	##
	## Build tools
	##

	apt-key:  url https://apt.kitware.com/keys/kitware-archive-latest.asc
	apt-repo: deb https://apt.kitware.com/${os_release_ID:?} ${cmake_os_release_VERSION_CODENAME:?} main

	skip: cmake
	skip: cmake-curses-gui
	skip: cmake-doc
	skip: cmake-extras

END

##

[ -z "${emacs_os_release_VERSION_CODENAME}" ] ||

cat <<-END

	##
	## Text editors [extra]
	##

	apt-repo: ppa:kelleyk/emacs

	skip: emacs

END

##

[ -z "${p4_os_release_VERSION_CODENAME}" ] ||

cat <<-END

	##
	## Version control systems
	##

	apt-key:  url https://package.perforce.com/perforce.pubkey
	apt-repo: deb http://package.perforce.com/apt/${os_release_ID:?} ${p4_os_release_VERSION_CODENAME:?} release

	skip: p4

END

