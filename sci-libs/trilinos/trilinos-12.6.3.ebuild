# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-multilib

S="${WORKDIR}/trilinos-${PV}-Source"

DESCRIPTION="Scientific library collection for large scale problems"
HOMEPAGE="http://trilinos.sandia.gov/"
SRC_URI="https://trilinos.org/oldsite/download/files/trilinos-${PV}-Source.tar.bz2"

KEYWORDS="~amd64 ~x86 ~amd64-linux"

LICENSE="BSD LGPL-2.1"
SLOT_DIR="trilinos_xyce_0"
SLOT="${SLOT_DIR}/${PVR}"

IUSE="
	mpi
	shared
	pic
"

# TODO: fix export cmake function for tests
RESTRICT="test mirror"

RDEPEND="
	|| (
		sci-libs/atlas
		(
			virtual/blas
			virtual/lapack
		)
	)

	sci-libs/amd
	sci-libs/umfpack

"
DEPEND="${RDEPEND}"

PATCHES=(
#	"${FILESDIR}/${PN}-11.14.1-fix-install-paths.patch"
#	"${FILESDIR}/${PN}-12.6.2-fix_install_paths_for_destdir.patch"
	"${FILESDIR}/${P}-makefile-export-dirs.patch"
)

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=$(usex shared ON OFF)
		-DTrilinos_ENABLE_NOX=ON \
		-DNOX_ENABLE_LOCA=ON \
		-DTrilinos_ENABLE_EpetraExt=ON \
		-DEpetraExt_BUILD_BTF=ON \
		-DEpetraExt_BUILD_EXPERIMENTAL=ON \
		-DEpetraExt_BUILD_GRAPH_REORDERINGS=ON \
		-DTrilinos_ENABLE_TrilinosCouplings=ON \
		-DTrilinos_ENABLE_Ifpack=ON \
		-DTrilinos_ENABLE_Isorropia=ON \
		-DTrilinos_ENABLE_AztecOO=ON \
		-DTrilinos_ENABLE_Belos=ON \
		-DTrilinos_ENABLE_Teuchos=ON \
		-DTeuchos_ENABLE_COMPLEX=ON \
		-DTrilinos_ENABLE_Amesos=ON \
		-DAmesos_ENABLE_KLU=ON \
		-DAmesos_ENABLE_UMFPACK=ON \
		-DTrilinos_ENABLE_Sacado=ON \
		-DTrilinos_ENABLE_Kokkos=OFF \
		-DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF \
		-DTPL_ENABLE_AMD=ON \
		-DTPL_ENABLE_UMFPACK=ON \
		-DTPL_ENABLE_BLAS=ON \
		-DTPL_ENABLE_LAPACK=ON \
		-DTrilinos_INSTALL_LIB_DIR="${EPREFIX}/usr/$(get_libdir)/${SLOT_DIR}" \
		-DTrilinos_INSTALL_INCLUDE_DIR="${EPREFIX}/usr/include/${SLOT_DIR}"
	)
	use mpi && mycmakeargs+=(
		-DTPL_ENABLE_ParMETIS=ON \
		-DTrilinos_ENABLE_Zoltan=ON \
		-DTrilinos_ENABLE_ShyLU=ON \
		-DTPL_ENABLE_MPI=ON
	)
	if use pic; then
		mycmakeargs+=(
			-DCMAKE_POSITION_INDEPENDENT_CODE=TRUE
		)
	fi

	CMAKE_BUILD_TYPE=RELEASE

	cmake-utils_src_configure
}

multilib_src_install() {
	docinto "/usr/share/doc/${PV}/${SLOT}"
	cmake-utils_src_install
}
