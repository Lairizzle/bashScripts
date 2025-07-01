#!/usr/bin/env bash

set -e

echo "===> Arch PKGBUILD Generator & Installer (In-Repo Mode)"

# Ensure we're inside a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "This directory is not a Git repository. Please run this from inside a cloned repo."
    exit 1
fi

# Current repo directory
srcdir="$PWD"
reponame=$(basename "$srcdir")
default_version=$(git describe --tags --always 2>/dev/null || echo "1.0.0")

# Prompt for package info
read -rp "Program name [${reponame}]: " pkgname
pkgname="${pkgname:-$reponame}"

read -rp "Version [${default_version}]: " pkgver
pkgver="${pkgver:-$default_version}"

read -rp "Build system (cmake/configure/meson/custom) [cmake]: " build_system
build_system="${build_system:-cmake}"

read -rp "Any runtime dependencies? (space-separated, or leave blank): " deps

# Prepare build root folder
buildroot="$HOME/aurbuild/$pkgname"
mkdir -p "$buildroot"
cd "$buildroot"

# Create source tarball with prefix folder in buildroot
echo "===> Archiving current Git repo..."
git -C "$srcdir" archive --format=tar.gz --prefix="${pkgname}-${pkgver}/" HEAD > "$buildroot/${pkgname}-${pkgver}.tar.gz"

# Generate PKGBUILD
echo "===> Creating PKGBUILD..."
cat > PKGBUILD <<EOF
pkgname=$pkgname
pkgver=$pkgver
pkgrel=1
arch=('x86_64')
url='$(git -C "$srcdir" config --get remote.origin.url || echo "https://example.com")'
license=('custom')
depends=($deps)
makedepends=('gcc' 'make' 'cmake' 'meson' 'autoconf' 'automake' 'libtool')
source=('$pkgname-$pkgver.tar.gz')
sha256sums=('SKIP')

build() {
  cd "\$srcdir/$pkgname-$pkgver"
EOF

case "$build_system" in
  cmake)
cat >> PKGBUILD <<'EOF'
  mkdir -p build
  cd build
  cmake -DCMAKE_INSTALL_PREFIX=/usr ..
  make
EOF
  ;;
  configure)
cat >> PKGBUILD <<'EOF'
  ./configure --prefix=/usr
  make
EOF
  ;;
  meson)
cat >> PKGBUILD <<'EOF'
  meson setup build --prefix=/usr
  meson compile -C build
EOF
  ;;
  custom)
cat >> PKGBUILD <<'EOF'
  echo "Custom build steps go here"
  exit 1
EOF
  ;;
  *)
    echo "Unsupported build system: $build_system"
    exit 1
    ;;
esac

cat >> PKGBUILD <<'EOF'
}

package() {
  cd "$srcdir/$pkgname-$pkgver"
EOF

if [[ "$build_system" == "cmake" || "$build_system" == "meson" ]]; then
cat >> PKGBUILD <<'EOF'
  cd build
EOF
fi

cat >> PKGBUILD <<'EOF'
  make DESTDIR="$pkgdir" install
}
EOF

# Build and install
echo "===> Building package..."
makepkg -si --noconfirm

echo "Done! You can uninstall it with: sudo pacman -Rns $pkgname"

