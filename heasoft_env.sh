# soft_env.sh - FreeBSD HEASoft build environment (idempotent)

# ==========================================================
# HEASoft source + build tag (adjust if your path changes)
# ==========================================================
HEASOFT_SRC="/home/agarg/src/heasoft-6.36"
HEA_BLD_TAG="aarch64-unknown-freebsd15.0"

HEA_HEACORE_LIB="${HEASOFT_SRC}/heacore/BLD/${HEA_BLD_TAG}/lib"
HEA_HEAGEN_LIB="${HEASOFT_SRC}/heagen/BLD/${HEA_BLD_TAG}/lib"
HEA_ATT_LIB="${HEASOFT_SRC}/attitude/BLD/${HEA_BLD_TAG}/lib"

# ==========================================================
# PATH first (so wrapper compilers are found)
# ==========================================================
export PATH="$HOME/bin:$PATH"

# ==========================================================
# GNU toolchain (pin versions)
# If you use wrapper scripts in ~/bin, keep CC/CXX as below.
# If you do NOT use wrappers, replace CC/CXX with /usr/local/bin/gcc14 and g++14.
# ==========================================================
export CC="/usr/local/bin/gcc14"
export CXX="/usr/local/bin/g++14"
export FC=/usr/local/bin/gfortran14
export F77=/usr/local/bin/gfortran14
export MAKE=/usr/local/bin/gmake

# ==========================================================
# Baseline build flags (keep consistent across configure/make)
# ==========================================================
: "${CFLAGS:=-O2 -pipe -fPIC}"
: "${CXXFLAGS:=-O2 -pipe -fPIC -DgFortran}"
: "${FFLAGS:=-O2 -pipe -fPIC}"
export CFLAGS CXXFLAGS FFLAGS

# ==========================================================
# pkg-config (FreeBSD /usr/local)
# ==========================================================
: "${PKG_CONFIG_PATH:=/usr/local/libdata/pkgconfig:/usr/local/lib/pkgconfig}"
export PKG_CONFIG_PATH

# ==========================================================
# Prefer /usr/local headers/libs (idempotent)
# ==========================================================
case " ${CPPFLAGS:-} " in
  *" -I/usr/local/include "*) : ;;
  *) CPPFLAGS="-I/usr/local/include ${CPPFLAGS:-}" ;;
esac

case " ${CPPFLAGS:-} " in
  *" -DgFortran "*) : ;;
  *) CPPFLAGS="-DgFortran ${CPPFLAGS:-}" ;;
esac

case " ${LDFLAGS:-} " in
  *" -L/usr/local/lib "*) : ;;
  *) LDFLAGS="-L/usr/local/lib ${LDFLAGS:-}" ;;
esac

# ==========================================================
# HEASoft internal library paths (build-tree)
# ==========================================================
for libdir in "$HEA_HEACORE_LIB" "$HEA_HEAGEN_LIB" "$HEA_ATT_LIB"
do
  case " ${LDFLAGS:-} " in
    *" -L${libdir} "*) : ;;
    *) LDFLAGS="-L${libdir} ${LDFLAGS:-}" ;;
  esac
done

export CPPFLAGS LDFLAGS

# ==========================================================
# Runtime loader paths (helps test programs during build)
# ==========================================================
for libdir in "$HEA_HEACORE_LIB" "$HEA_HEAGEN_LIB" "$HEA_ATT_LIB"
do
  case " ${LD_LIBRARY_PATH:-} " in
    *"${libdir}"*) : ;;
    *) LD_LIBRARY_PATH="${libdir}:${LD_LIBRARY_PATH:-}" ;;
  esac
done

export LD_LIBRARY_PATH

# ==========================================================
# Link requirements (minimal + idempotent)
# ==========================================================
case " ${LIBS:-} " in
  *" -lexecinfo "*) : ;;
  *) LIBS="-lexecinfo ${LIBS:-}" ;;
esac

# Do not force -lfftw3 globally; it causes libtool .la resolution
# problems in unrelated sub-builds (for example Tcl/Tk). Link FFTW
# only in the specific targets that need it.

# clean whitespace
LIBS=$(echo "${LIBS:-}" | sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//')
export LIBS

# ==========================================================
# Tcl/Tk
# ==========================================================
export TCLSH=/usr/local/bin/tclsh8.6
export WISH=/usr/local/bin/wish8.6

# Prefer system tclreadline package path for XSPEC prompt support.
# Keep this package-path driven and avoid forcing TCLRL_LIBDIR.
for tclrl_dir in /usr/local/lib/tclreadline2.4.0 /usr/local/lib/tclreadline2.1.0
do
  if [ -d "$tclrl_dir" ]; then
    case " ${TCLLIBPATH:-} " in
      *" ${tclrl_dir} "*) : ;;
      *) TCLLIBPATH="${tclrl_dir} ${TCLLIBPATH:-}" ;;
    esac
  fi
done
export TCLLIBPATH
unset TCLRL_LIBDIR

# ==========================================================
# PGPLOT
# ==========================================================
export PGPLOT_SYS=freebsd

# ==========================================================
# Optional: quick diagnostic summary (interactive shells only)
# ==========================================================
case "$-" in
  *i*)
    echo "HEASoft env loaded:"
    echo "  CC=${CC}  FC=${FC}"
    echo "  CFLAGS=${CFLAGS}"
    echo "  CPPFLAGS=${CPPFLAGS}"
    echo "  LDFLAGS=${LDFLAGS}"
    echo "  LIBS=${LIBS}"
    echo "  PKG_CONFIG_PATH=${PKG_CONFIG_PATH}"
    ;;
esac
