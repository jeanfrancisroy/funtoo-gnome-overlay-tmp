# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python2_{6,7} )

inherit autotools eutils gnome2 multilib pax-utils python-r1

DESCRIPTION="Provides core UI functions for the GNOME 3 desktop"
HOMEPAGE="http://live.gnome.org/GnomeShell"

LICENSE="GPL-2+ LGPL-2+"
SLOT="0"
IUSE="+bluetooth +i18n +networkmanager systemd"
KEYWORDS="*"

# libXfixes-5.0 needed for pointer barriers
# TODO: gstreamer support is currently automagical:
# gstreamer? ( >=media-libs/gstreamer-0.11.92 )
COMMON_DEPEND="
	>=app-accessibility/at-spi2-atk-2.5.3
	>=dev-libs/atk-2[introspection]
	>=app-crypt/gcr-3.3.90[introspection]
	>=dev-libs/glib-2.31.6:2
	>=dev-libs/gjs-1.33.2
	>=dev-libs/gobject-introspection-0.10.1
	>=x11-libs/gtk+-3.3.9:3[introspection]
	>=media-libs/clutter-1.11.11:1.0[introspection]
	>=dev-libs/json-glib-0.13.2
	>=dev-libs/libcroco-0.6.2:0.6
	>=gnome-base/gnome-desktop-3.5.1:3=[introspection]
	>=gnome-base/gsettings-desktop-schemas-3.5.4
	>=gnome-base/gnome-keyring-3.3.90
	>=gnome-base/gnome-menus-3.5.3:3[introspection]
	gnome-base/libgnome-keyring
	>=gnome-extra/evolution-data-server-3.5.3:=
	>=media-libs/gstreamer-0.11.92:1.0
	>=net-im/telepathy-logger-0.2.4[introspection]
	>=net-libs/telepathy-glib-0.19[introspection]
	>=sys-auth/polkit-0.100[introspection]
	>=x11-libs/libXfixes-5.0
	>=x11-wm/mutter-3.6.3[introspection]
	>=x11-libs/startup-notification-0.11

	${PYTHON_DEPS}
	dev-python/pygobject:3[${PYTHON_USEDEP}]

	dev-libs/dbus-glib
	dev-libs/libxml2:2
	gnome-base/librsvg
	media-libs/libcanberra
	media-libs/mesa
	media-sound/pulseaudio
	>=net-libs/libsoup-2.40:2.4[introspection]
	x11-libs/libX11
	x11-libs/gdk-pixbuf:2[introspection]
	x11-libs/pango[introspection]
	x11-apps/mesa-progs

	bluetooth? ( >=net-wireless/gnome-bluetooth-3.5[introspection] )
	networkmanager? ( >=net-misc/networkmanager-0.8.999[introspection] )
	systemd? ( >=sys-apps/systemd-31 )
"
# Runtime-only deps are probably incomplete and approximate.
# Introspection deps generated using:
#  grep -roe "imports.gi.*" gnome-shell-* | cut -f2 -d: | sort | uniq
# Each block:
# 1. Pull in polkit-0.101 for pretty authorization dialogs
# 2. Introspection stuff needed via imports.gi.*
# 3. gnome-session is needed for gnome-session-quit
# 4. Control shell settings
# 5. xdg-utils needed for xdg-open, used by extension tool
# 6. gnome-icon-theme-symbolic and dejavu font neeed for various icons & arrows
# 7. IBus is needed for i18n integration
# 8. mobile-broadband-provider-info, timezone-data for shell-mobile-providers.c
RDEPEND="${COMMON_DEPEND}
	>=sys-auth/polkit-0.101[introspection]

	>=app-accessibility/caribou-0.3
	>=gnome-base/gdm-3.5[introspection]
	>=gnome-base/libgnomekbd-2.91.4[introspection]
	media-libs/cogl[introspection]
	>=sys-apps/accountsservice-0.6.14[introspection]
	sys-power/upower[introspection]

	>=gnome-base/gnome-session-2.91.91
	>=gnome-base/gnome-settings-daemon-2.91
	>=gnome-base/gnome-control-center-2.91.92-r1[bluetooth(+)?]

	x11-misc/xdg-utils

	media-fonts/dejavu
	x11-themes/gnome-icon-theme-symbolic

	i18n? ( || >=app-i18n/ibus-1.4.99[dconf,gtk3,introspection] 
	           >=app-i18n/ibus-1.5.4-r1[gtk3,introspection] )
	networkmanager? (
		net-misc/mobile-broadband-provider-info
		sys-libs/timezone-data )

	!systemd? ( sys-auth/consolekit )
"
DEPEND="${COMMON_DEPEND}
	dev-libs/libxslt
	>=dev-util/gtk-doc-am-1.17
	>=dev-util/intltool-0.40
	gnome-base/gnome-common
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
	!!=dev-lang/spidermonkey-1.8.2*"
# libmozjs.so is picked up from /usr/lib while compiling, so block at build-time
# https://bugs.gentoo.org/show_bug.cgi?id=360413

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_prepare() {
	# Fix automagic gnome-bluetooth dep, bug #398145
	epatch "${FILESDIR}/${PN}-3.5.x-bluetooth-flag.patch"

	# Make networkmanager optional, bug #398593
	epatch "${FILESDIR}/${PN}-3.6.0-networkmanager-flag.patch"

	eautoreconf
	gnome2_src_prepare
}

src_configure() {
	# Do not error out on warnings
	gnome2_src_configure \
		--enable-man \
		--enable-compile-warnings=maximum \
		--disable-jhbuild-wrapper-script \
		$(use_with bluetooth) \
		$(use_enable networkmanager) \
		$(use_with systemd) \
		BROWSER_PLUGIN_DIR="${EPREFIX}"/usr/$(get_libdir)/nsbrowser/plugins
}

src_install() {
	gnome2_src_install
	python_replicate_script "${ED}/usr/bin/gnome-shell-extension-tool"
	python_replicate_script "${ED}/usr/bin/gnome-shell-perf-tool"

	# Required for gnome-shell on hardened/PaX, bug #398941
	# Future-proof for >=spidermonkey-1.8.7 following polkit's example
	if has_version '<dev-lang/spidermonkey-1.8.7'; then
		pax-mark mr "${ED}usr/bin/gnome-shell"
	elif has_version '>=dev-lang/spidermonkey-1.8.7[jit]'; then
		pax-mark m "${ED}usr/bin/gnome-shell"
	fi
	# Required for gnome-shell on hardened/PaX #457146 and #457194
	# PaX EMUTRAMP need to be on
	if has_version '>=dev-libs/libffi-3.0.13[pax_kernel]'; then
		pax-mark E "${ED}usr/bin/gnome-shell"
	fi
}

pkg_postinst() {
	gnome2_pkg_postinst

	if ! has_version 'media-libs/gst-plugins-good:1.0' || \
	   ! has_version 'media-plugins/gst-plugins-vpx:1.0'; then
		ewarn "To make use of GNOME Shell's built-in screen recording utility,"
		ewarn "you need to either install media-libs/gst-plugins-good:1.0"
		ewarn "and media-plugins/gst-plugins-vpx:1.0, or use dconf-editor to change"
		ewarn "apps.gnome-shell.recorder/pipeline to what you want to use."
	fi

	if ! has_version ">=x11-base/xorg-server-1.11"; then
		ewarn "If you use multiple screens, it is highly recommended that you"
		ewarn "upgrade to >=x11-base/xorg-server-1.11 to be able to make use of"
		ewarn "pointer barriers which will make it easier to use hot corners."
	fi

	if has_version "<x11-drivers/ati-drivers-12"; then
		ewarn "GNOME Shell has been reported to show graphical corruption under"
		ewarn "x11-drivers/ati-drivers-11.*; you may want to use GNOME in"
		ewarn "fallback mode, or switch to open-source drivers."
	fi

	if has_version "media-libs/mesa[video_cards_radeon]" ||
	   has_version "media-libs/mesa[video_cards_r300]" ||
	   has_version "media-libs/mesa[video_cards_r600]"; then
		elog "GNOME Shell is unstable under classic-mode r300/r600 mesa drivers."
		elog "Make sure that gallium architecture for r300 and r600 drivers is"
		elog "selected using 'eselect mesa'."
		if ! has_version "media-libs/mesa[gallium]"; then
			ewarn "You will need to emerge media-libs/mesa with USE=gallium."
		fi
	fi

	if has_version "media-libs/mesa[video_cards_intel]" ||
	   has_version "media-libs/mesa[video_cards_i915]" ||
	   has_version "media-libs/mesa[video_cards_i965]"; then
		elog "GNOME Shell is unstable under gallium-mode i915/i965 mesa drivers."
		elog "Make sure that classic architecture for i915 and i965 drivers is"
		elog "selected using 'eselect mesa'."
		if ! has_version "media-libs/mesa[classic]"; then
			ewarn "You will need to emerge media-libs/mesa with USE=classic."
		fi
	fi
}
