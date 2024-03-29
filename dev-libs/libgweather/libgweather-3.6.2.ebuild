# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="Library to access weather information from online services"
HOMEPAGE="https://live.gnome.org/LibGWeather"

LICENSE="GPL-2+"
SLOT="2/3-1" # subslot = 3-(libgweather-3 soname suffix)
IUSE="+introspection"
KEYWORDS="~*"

COMMON_DEPEND="
	>=x11-libs/gtk+-2.90.0:3[introspection?]
	>=dev-libs/glib-2.13
	>=net-libs/libsoup-gnome-2.25.1:2.4
	>=dev-libs/libxml2-2.6.0
	>=sys-libs/timezone-data-2010k

	introspection? ( >=dev-libs/gobject-introspection-0.9.5 )
"
RDEPEND="${COMMON_DEPEND}
	!<gnome-base/gnome-applets-2.22.0
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/gtk-doc-am-1.9
	>=dev-util/intltool-0.50
	sys-devel/gettext
	virtual/pkgconfig
"

src_configure() {
	DOCS="AUTHORS ChangeLog MAINTAINERS NEWS"
	# Do not add --disable-all-translations-in-one-xml : it will enable them
	gnome2_src_configure \
		--enable-locations-compression \
		--disable-static \
		$(use_enable introspection)
}
