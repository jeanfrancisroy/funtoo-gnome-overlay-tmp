# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"
VALA_MIN_API_VERSION="0.16"
VALA_USE_DEPEND="vapigen"

inherit gnome2 vala

DESCRIPTION="Unicode character map viewer and library"
HOMEPAGE="http://live.gnome.org/Gucharmap"

LICENSE="GPL-3"
SLOT="2.90"
KEYWORDS="*"
IUSE="cjk +introspection test vala"
REQUIRED_USE="vala? ( introspection )"

COMMON_DEPEND="
	>=dev-libs/glib-2.32
	>=x11-libs/pango-1.2.1[introspection?]
	>=x11-libs/gtk+-3.4.0:3[introspection?]

	introspection? ( >=dev-libs/gobject-introspection-0.9.0 )
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-extra/gucharmap-3:0
"
DEPEND="${RDEPEND}
	app-text/yelp-tools
	>=dev-util/gtk-doc-am-1
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
	test? (	app-text/docbook-xml-dtd:4.1.2 )
	vala? ( $(vala_depend) )
"

src_prepare() {
	DOCS="AUTHORS ChangeLog NEWS README TODO"
	G2CONF="${G2CONF}
		--disable-static
		$(use_enable introspection)
		$(use_enable cjk unihan)
		$(use_enable vala)"
	# Do not add ITSTOOL=$(type -P true); yelp-tools is a true required
	# dependency here for some LINGUAS.

	# prevent file collisions with slot 0
	sed -e "s:GETTEXT_PACKAGE=gucharmap$:GETTEXT_PACKAGE=gucharmap-${SLOT}:" \
		-i configure.ac configure || die "sed configure.ac configure failed"

	use vala && vala_src_prepare
	gnome2_src_prepare

	# avoid autoreconf
	sed -e 's/-Wall //g' -i configure || die "sed failed"
}
