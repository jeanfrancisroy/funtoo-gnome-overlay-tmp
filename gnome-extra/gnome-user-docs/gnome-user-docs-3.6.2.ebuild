# Distributed under the terms of the GNU General Public License v2

EAPI="5"
GCONF_DEBUG="no"

inherit gnome2

DESCRIPTION="GNOME end user documentation"
HOMEPAGE="http://www.gnome.org/"

LICENSE="CC-BY-3.0"
SLOT="0"
KEYWORDS="~*"
IUSE="test"

# Newer gnome-doc-utils is needed for RNGs
# libxml2 needed for xmllint
# scrollkeeper is referenced in gnome-user-docs.spec, but is not used
RDEPEND=""
DEPEND="test? (
		>=app-text/gnome-doc-utils-0.20.5
		dev-libs/libxml2 )"
# eautoreconf requires:
#	app-text/yelp-tools
# rebuilding translations requires:
#	dev-libs/libxml2
#	dev-util/gettext
#	dev-util/itstool

# This ebuild does not install any binaries
RESTRICT="binchecks strip"

DOCS="AUTHORS ChangeLog NEWS README"

src_configure() {
	# itstool is only needed for rebuilding translations
	G2CONF="${G2CONF} ITSTOOL=$(type -P true)"
	# xmllint is only needed for tests
	use test || G2CONF="${G2CONF} XMLLINT=$(type -P true)"
	gnome2_src_configure
}

src_compile() {
	# Do not compile; "make all" with unset LINGUAS rebuilds all translations,
	# which can take > 2 hours on a Core i7.
	return
}
