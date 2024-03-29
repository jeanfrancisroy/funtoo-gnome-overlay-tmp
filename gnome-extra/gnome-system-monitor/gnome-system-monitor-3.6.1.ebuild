# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="The Gnome System Monitor"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
IUSE="systemd"
KEYWORDS="~*"

RDEPEND=">=dev-libs/glib-2.28:2
	>=x11-libs/libwnck-2.91.0:3
	>=gnome-base/libgtop-2.28.2:2
	>=x11-libs/gtk+-3:3[X(+)]
	>=x11-themes/gnome-icon-theme-2.31
	>=dev-cpp/gtkmm-3:3.0
	>=dev-cpp/glibmm-2.34:2
	>=dev-libs/libxml2-2.0:2
	>=gnome-base/librsvg-2.35:2

	systemd? ( >=sys-apps/systemd-38 )
"
DEPEND="${RDEPEND}
	>=app-text/gnome-doc-utils-0.20
	>=dev-util/intltool-0.41.0
	>=sys-devel/gettext-0.17
	virtual/pkgconfig

	systemd? ( !=sys-apps/systemd-43* )
"

src_configure() {
	G2CONF="${G2CONF}
		$(use_enable systemd)
		ITSTOOL=$(type -P true)"
	gnome2_src_configure
}
