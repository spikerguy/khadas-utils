# Maintainer : Dan Johansen <strit@manjaro.org>
# Contributor: Spikerguy <tech@fkardame.com>

pkgname=khadas-utils
pkgver=1
pkgrel=0
pkgdesc="Khadas Vim3 Fan"
arch=('any')
url="https://www.manjaro.org"
license=('GPL')
depends=('busybox' 'i2c-tools')
#install=$pkgname.install
source=("fan"
        )
md5sums=('434313e1653bda9e627673d77262a62c'
         )

package() {
   install -Dm755 "${srcdir}/fan" -t "${pkgdir}/usr/bin/"
}

