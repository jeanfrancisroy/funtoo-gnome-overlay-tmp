# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/udisks/udisks-1.0.4-r5.ebuild,v 1.12 2013/08/09 19:17:15 ssuominen Exp $

EAPI=5
inherit eutils bash-completion-r1 linux-info udev

DESCRIPTION="Daemon providing interfaces to work with storage devices"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/udisks"
SRC_URI="http://hal.freedesktop.org/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="debug nls remote-access selinux"

COMMON_DEPEND=">=dev-libs/dbus-glib-0.100
	>=dev-libs/glib-2.30
	>=dev-libs/libatasmart-0.19
	>=sys-auth/polkit-0.110
	>=sys-apps/dbus-1.6
	>=sys-apps/sg3_utils-1.27.20090411
	>=sys-block/parted-3
	>=sys-fs/lvm2-2.02.66
	>=virtual/udev-197[gudev,hwdb(+)]
	selinux? ( sec-policy/selinux-devicekit )"
# util-linux -> mount, umount, swapon, swapoff (see also #403073)
RDEPEND="${COMMON_DEPEND}
	>=sys-apps/util-linux-2.20.1-r2
	virtual/eject
	remote-access? ( net-dns/avahi )"
DEPEND="${COMMON_DEPEND}
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	dev-util/intltool
	virtual/pkgconfig"

pkg_setup() {
	# Listing only major arch's here to avoid tracking kernel's defconfig
	if use amd64 || use arm || use ppc || use ppc64 || use x86; then
		CONFIG_CHECK="~!IDE" #319829
		CONFIG_CHECK+=" ~NLS_UTF8" #425562
		kernel_is lt 3 10 && CONFIG_CHECK+=" ~USB_SUSPEND" #331065, #477278
		linux-info_pkg_setup
	fi
}

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-1.0.2-ntfs-3g.patch \
		"${FILESDIR}"/${P}-kernel-2.6.36-compat.patch \
		"${FILESDIR}"/${P}-drop-pci-db.patch \
		"${FILESDIR}"/${P}-revert-floppy.patch

	sed -i -e "s:/lib/udev:$(udev_get_udevdir):" data/80-udisks.rules || die
}

src_configure() {
	# device-mapper -> lvm2 -> mandatory depend -> force enabled
	econf \
		--localstatedir="${EPREFIX}"/var \
		--disable-static \
		$(use_enable debug verbose-mode) \
		--enable-man-pages \
		--disable-gtk-doc \
		--enable-lvm2 \
		--enable-dmmp \
		$(use_enable remote-access) \
		$(use_enable nls) \
		--with-html-dir="${EPREFIX}"/deprecated
}

src_test() {
	ewarn "Skipping testsuite because sys-fs/udisks:0 is deprecated"
	ewarn "in favour of sys-fs/udisks:2."
}

src_install() {
	emake \
		DESTDIR="${D}" \
		slashsbindir=/usr/sbin \
		slashlibdir=/usr/lib \
		udevhelperdir="$(udev_get_udevdir)" \
		udevrulesdir="$(udev_get_udevdir)"/rules.d \
		install #398081

	dodoc AUTHORS HACKING NEWS README

	rm -f "${ED}"/etc/profile.d/udisks-bash-completion.sh
	newbashcomp tools/udisks-bash-completion.sh ${PN}

	prune_libtool_files --all

	keepdir /media
	keepdir /var/lib/udisks #383091

	rm -rf "${ED}"/deprecated
}
