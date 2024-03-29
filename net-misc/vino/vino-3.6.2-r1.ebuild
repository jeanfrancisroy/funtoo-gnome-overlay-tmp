# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"

inherit eutils gnome2

DESCRIPTION="An integrated VNC server for GNOME"
HOMEPAGE="http://live.gnome.org/Vino"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~*"
IUSE="avahi crypt gnome-keyring ipv6 jpeg libnotify networkmanager ssl +telepathy +zlib"

# cairo used in vino-fb
# libSM and libICE used in eggsmclient-xsmp
RDEPEND=">=dev-libs/glib-2.26:2
	>=x11-libs/gtk+-3.0.0:3
	>=dev-libs/libgcrypt-1.1.90:=
	>=net-libs/libsoup-2.24:2.4

	dev-libs/dbus-glib
	x11-libs/cairo:=
	x11-libs/pango[X]
	x11-libs/libICE
	x11-libs/libX11
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libSM
	x11-libs/libXtst

	avahi? ( >=net-dns/avahi-0.6:=[dbus] )
	crypt? ( >=dev-libs/libgcrypt-1.1.90:= )
	gnome-keyring? ( app-crypt/libsecret )
	jpeg? ( virtual/jpeg:0= )
	libnotify? ( >=x11-libs/libnotify-0.7.0:= )
	networkmanager? ( >=net-misc/networkmanager-0.7 )
	ssl? ( >=net-libs/gnutls-2.2.0:= )
	telepathy? ( >=net-libs/telepathy-glib-0.18.0 )
	zlib? ( sys-libs/zlib:= )"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5
	>=dev-util/intltool-0.50
	virtual/pkgconfig
	app-crypt/libsecret"
# libsecret is always required at build time per bug 322763

# bug #394611; tight encoding requires zlib encoding
REQUIRED_USE="jpeg? ( zlib )"

src_prepare() {
	G2CONF="${G2CONF}
		--disable-schemas-compile
		--enable-http-server
		--with-gcrypt
		$(use_with avahi)
		$(use_with crypt gcrypt)
		$(use_enable ipv6)
		$(use_with jpeg)
		$(use_with gnome-keyring secret)
		$(use_with libnotify)
		$(use_with networkmanager network-manager)
		$(use_with ssl gnutls)
		$(use_with telepathy)
		$(use_with zlib)"

	# clipboard leak to unauthenticated clients, bug #434930
	epatch "${FILESDIR}/${P}-clipboard-leak.patch"

	# <glib-2.31 compatibility
	rm -v server/vino-marshal.{c,h} || die
	gnome2_src_prepare
}
