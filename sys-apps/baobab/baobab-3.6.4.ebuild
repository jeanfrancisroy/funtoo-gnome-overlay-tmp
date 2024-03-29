# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="Disk usage browser for GNOME 3"
HOMEPAGE="https://live.gnome.org/GnomeUtils"

LICENSE="GPL-2+ FDL-1.1+"
SLOT="0"
IUSE=""
KEYWORDS="~*"

COMMON_DEPEND="
	>=dev-libs/glib-2.30.0:2
	gnome-base/libgtop:2=
	x11-libs/cairo
	x11-libs/gdk-pixbuf
	>=x11-libs/gtk+-3.5.9:3
	x11-libs/pango
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gsettings-desktop-schemas
	!<gnome-extra/gnome-utils-3.4
"
# ${PN} was part of gnome-utils before 3.4
DEPEND="${COMMON_DEPEND}
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

src_configure() {
	gnome2_src_configure \
		ITSTOOL=$(type -P true) \
		XMLLINT=$(type -P true) \
		VALAC=$(type -P true) \
		VAPIGEN=$(type -P true)
}
