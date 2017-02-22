# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6

#inherit eutils autotools
inherit eutils cmake-utils

DESCRIPTION="A code generator that converts electrical compact device models specified in high-level description language into ready-to-compile c code for the API of spice simulators."
HOMEPAGE="https://github.com/Qucs/ADMS/"
SRC_URI="https://github.com/Qucs/ADMS/archive/release-${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	sys-devel/libtool
"

DEPEND="${RDEPEND}
	sys-devel/flex
	sys-devel/bison
	dev-perl/XML-LibXML
"

S="${WORKDIR}/ADMS-release-${PV}"

src_configure() {
	#Currently some stupid stuff in CMAKE, so this is needed.
	CMAKE_IN_SOURCE_BUILD=yes

	local mycmakeargs=(
		-DUSE_MAINTAINER_MODE=on
	)

	cmake-utils_src_configure
}
