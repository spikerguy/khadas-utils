#Maintainer : Dan Johansen <strit@manjaro.org>
#Contributor: Spikerguy <tech@fkardame.com>

pkgname=khadas-utils
pkgver=1
pkgrel=0
pkgdesc="Khadas Vim3 Fan"
arch=('any')
url="https://www.manjaro.org"
license=('GPL')
depends=('busybox' 'i2c-tools')
source=("fan"
		 "khadas-utils.service"
        )
md5sums=('c57c34b284ccc801fe361b8536e06729'
		 '5d1400c0f6e6ba125e64727482258915' 
         )

package() {
   install -Dm755 "${srcdir}/fan" -t "${pkgdir}/usr/bin/"
   install -Dm755 "${srcdir}/khadas-utils.service" -t "${pkgdir}/usr/lib/systemd/system/"
}

