# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit flag-o-matic autotools multilib-build

DESCRIPTION="The Xyce Parallel Electronic Simulator is a SPICE-compatible circuit simulator"
HOMEPAGE="https://xyce.sandia.gov/"
SRC_URI="https://xyce.sandia.gov/downloads/_assets/documents/Xyce-${PV}.tar.gz
doc? ( https://xyce.sandia.gov/downloads/_assets/documents/Xyce_Docs-${PV}.tar.gz )"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~x86 ~amd64 ~amd64-linux"
RESTRICT="mirror fetch"

IUSE="mpi doc mkl shared adms"

TRILINOS_XYCE_SLOT="trilinos_xyce_${SLOT}"

RDEPEND="
	!mkl? ( sci-libs/fftw:=[${MULTILIB_USEDEP}] )
	mkl? ( sci-libs/mkl:=[fftw(+)] )

	mpi? (
		sci-libs/parmetis
		sys-cluster/openmpi[cxx,fortran,${MULTILIB_USEDEP}]
	)

	>=sci-libs/trilinos-11.2.4:${TRILINOS_XYCE_SLOT}=[mpi=,${MULTILIB_USEDEP}]
	!>=sci-libs/trilinos-12.6.4:${TRILINOS_XYCE_SLOT}

	adms? ( sci-electronics/adms )

	shared? ( || (
		sci-libs/trilinos[pic(-)]
		sci-libs/trilinos[shared]
	) )
"
#		virtual/mpi[cxx,fortran,${MULTILIB_USEDEP}]

DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex
	virtual/fortran
"

S="${WORKDIR}/Xyce-${PV}"
BUILD_DIR="${WORKDIR}/Xyce-${PV}_build"
S_DOCS="${WORKDIR}/Xyce_Docs-${PV}"

REQUIRED_USE="shared? ( !mpi )"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - Xyce-${PV}.tar.gz"
	einfo "  - [if USE=doc] Xyce_Docs-${PV}.tar.gz"
	einfo "from https://xyce.sandia.gov/downloads/source_code.html and place them in ${DISTDIR}"
}

src_prepare() {
	#Don't pollute /usr/libexec; use /usr/libexec/xyce instead
	for AC in $(find ${S} -type f -name 'Makefile.am')
	do
		sed -i 's/^libexec_SCRIPTS=/pkglibexec_SCRIPTS=/' ${AC}
		sed -i 's/\$(datadir)/\$(pkgdatadir)/' ${AC}
		sed -i 's/\$(libexecdir)/\$(pkglibexecdir)/' ${AC}
	done
	for AC in $(find ${S} -type f -name '*.m4')
	do
		sed -i 's/include\/Makefile.export/include\/'${TRILINOS_XYCE_SLOT}'\/Makefile.export/g' ${AC}
	done

	default

	eautoreconf
}

src_configure() {
	append-cxxflags -std=c++11
	append-cppflags "-I${EPREFIX}/usr/include/${TRILINOS_XYCE_SLOT}"
	append-ldflags "-L${EPREFIX}/usr/$(get_libdir)/${TRILINOS_XYCE_SLOT}"
	local myeconfargs=(
		$(use_enable mpi)
		$(use_enable shared)
		$(use_enable adms xyce-shareable)
		"ARCHDIR=${EPREFIX}/usr"
	)
	if use mpi; then
		myeconfargs+=(
			CC=mpicc
			CXX=mpicxx
			F77=mpif77
		)
	fi

	econf "${myeconfargs[@]}"
}

src_install() {
	if use doc; then
		DOCS=( $(find "${S_DOCS}" -type f -name '*.pdf') )
	fi

	default
}
