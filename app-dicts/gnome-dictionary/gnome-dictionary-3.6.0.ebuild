# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"

inherit gnome2

DESCRIPTION="Dictionary utility for GNOME 3"
HOMEPAGE="https://live.gnome.org/GnomeUtils"

LICENSE="GPL-2+ LGPL-2.1+ FDL-1.1+"
SLOT="0/6" # subslot = suffix of libgdict-1.0.so
IUSE="ipv6"
KEYWORDS="~*"

COMMON_DEPEND="
	>=dev-libs/glib-2.28:2
	x11-libs/cairo:=
	>=x11-libs/gtk+-3:3
	x11-libs/pango
"
RDEPEND="${COMMON_DEPEND}
	gnome-base/gsettings-desktop-schemas
	!<gnome-extra/gnome-utils-3.4
"
# ${PN} was part of gnome-utils before 3.4
DEPEND="${COMMON_DEPEND}
	>=dev-util/gtk-doc-am-1.15
	>=dev-util/intltool-0.40
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"

src_configure() {
	G2CONF="${G2CONF}
		$(use_enable ipv6)
		ITSTOOL=$(type -P true)"
	gnome2_src_configure
}
