#!/bin/bash

VER=`../bluray-film-player.linux.64bit --ver`
DATE=`date`
echo "Generowana wersja pakietów to: $VER"

czysc_katalog() {
  echo "Czyszczę katalogi..."
  cd debian
  rm -f -r .debhelper
  rm -f -r bluray-film-player
  rm -f -r etc
  rm -f -r usr
  rm -f bluray-film-player.debhelper.log
  rm -f bluray-film-player.substvars
  rm -f control
  rm -f changelog
  rm -f files
  rm -f postinst
  rm -f prerm
  rm -f ../usr/bin/bluray-film-player
  rm -f ../usr/bin/bluray-film-player.linux.32bit
  rm -f ../usr/bin/bluray-film-player.linux.64bit
  cd ..
}

czysc_isoimage() {
  echo "Czyszczę katalogi..."
  cd debian
  rm -f -r .debhelper
  rm -f -r bluray-film-player-image
  rm -f -r usr
  rm -f bluray-film-player-image.debhelper.log
  rm -f bluray-film-player-image.substvars
  rm -f changelog
  rm -f files
  cd ..
  rm -f ./usr/share/doc/bluray-film-player-image/files/version.txt
  rm -f ./usr/share/doc/bluray-film-player-image/files/bluray-film-player.linux.32bit
  rm -f ./usr/share/doc/bluray-film-player-image/files/bluray-film-player.linux.64bit
  rm -f ./usr/share/doc/bluray-film-player-image/files/bluray-film-player.32bit.exe
  rm -f ./usr/share/doc/bluray-film-player-image/files/bluray-film-player.64bit.exe
  rm -f ./usr/share/doc/bluray-film-player-image/files/bluray-film-player_all.deb.gz
}

prepare_control() {
  echo "Source: bluray-film-player" > debian/control
  echo "Section: multimedia" >> debian/control
  echo "Priority: extra" >> debian/control
  echo "Maintainer: Jacek Leszczyński <sam@bialan.pl>" >> debian/control
  echo "" >> debian/control
  echo "Package: bluray-film-player" >> debian/control
  if [ "$1" == "0" ]; then
    echo "Architecture: all" >> debian/control
  fi
  if [ "$1" == "32" ]; then
    echo "Architecture: i386" >> debian/control
  fi
  if [ "$1" == "64" ]; then
    echo "Architecture: amd64" >> debian/control
  fi
  echo "Depends: ${shlibs:Depends}, setcd, mpv | mplayer" >> debian/control
  echo "Description: Odtwarzacz zestawów filmowych" >> debian/control
  echo " Odtwarzacz zestawów filmowych" >> debian/control
}

prepare_changelog() {
  echo "bluray-film-player ($VER) experimental; urgency=low" > debian/changelog
  echo "" >> debian/changelog
  echo "  * Prepared by alien version 8.95" >> debian/changelog
  echo "  " >> debian/changelog
  echo "" >> debian/changelog
  echo " -- Jacek Leszczyński <sam@bialan.pl>  $DATE" >> debian/changelog
}

prepare_postinst() {
  echo '#!/bin/sh' >debian/postinst
  echo '' >>debian/postinst
  echo 'set -e' >>debian/postinst
  echo '' >>debian/postinst
  echo 'if [ "$1" = configure ]; then' >>debian/postinst
  echo '' >>debian/postinst
  echo '  AR=$(arch)' >>debian/postinst
  echo '  if [ "$AR" = "x86_64" ]; then' >>debian/postinst
  echo '    ln -s /usr/bin/bluray-film-player.linux.64bit /usr/bin/bluray-film-player' >>debian/postinst
  echo '  else' >>debian/postinst
  echo '    ln -s /usr/bin/bluray-film-player.linux.32bit /usr/bin/bluray-film-player' >>debian/postinst
  echo '  fi' >>debian/postinst
  echo '' >>debian/postinst
  echo 'fi' >>debian/postinst
  echo '' >>debian/postinst
  echo 'exit 0' >>debian/postinst
  echo '' >>debian/postinst
}

prepare_prerm() {
  echo '#!/bin/sh' > debian/prerm
  echo 'set -e' >> debian/prerm
  echo '# Automatically added by dh_installinit/11.2.1' >> debian/prerm
  echo 'rm -f /usr/bin/bluray-film-player' >> debian/prerm
  echo '# End automatically added section' >> debian/prerm
}

prepare_isoimage() {
  echo "$VER" > ./usr/share/doc/bluray-film-player-image/files/version.txt
  cp ../../bluray-film-player.linux.32bit ./usr/share/doc/bluray-film-player-image/files/
  cp ../../bluray-film-player.linux.64bit ./usr/share/doc/bluray-film-player-image/files/
  cp ../../bluray-film-player.32bit.exe ./usr/share/doc/bluray-film-player-image/files/
  cp ../../bluray-film-player.64bit.exe ./usr/share/doc/bluray-film-player-image/files/

  cp ../bluray-film-player_${VER}_all.deb ./usr/share/doc/bluray-film-player-image/files/
  gzip ./usr/share/doc/bluray-film-player-image/files/bluray-film-player_${VER}_all.deb
  mv ./usr/share/doc/bluray-film-player-image/files/bluray-film-player_${VER}_all.deb.gz ./usr/share/doc/bluray-film-player-image/files/bluray-film-player_all.deb.gz

  echo "bluray-film-player-image (1.0-1) experimental; urgency=low" > debian/changelog
  echo "" >> debian/changelog
  echo "  * Prepared by alien version 8.95" >> debian/changelog
  echo "  " >> debian/changelog
  echo "" >> debian/changelog
  echo " -- Jacek Leszczyński <sam@bialan.pl>  $DATE" >> debian/changelog
}

generuj_isoimage() {
  echo "Generuję pakiet IMAGEISO dla wszystkich architektur..."
  fakeroot ./debian/rules binary
}

generuj_all_bit() {
  echo "Generuję pakiet DEB dla wszystkich architektur..."
  czysc_katalog
  prepare_control 0
  prepare_changelog
  prepare_postinst
  prepare_prerm
  cp ../../bluray-film-player.linux.32bit ./usr/bin/
  cp ../../bluray-film-player.linux.64bit ./usr/bin/
  fakeroot ./debian/rules binary
}

generuj_32bit() {
  echo "Generuję pakiet DEB dla wersji 32 bitowej..."
  czysc_katalog
  prepare_control 32
  prepare_changelog
  cp ../../bluray-film-player.linux.32bit ./usr/bin/bluray-film-player
  fakeroot ./debian/rules binary
}

generuj_64bit() {
  echo "Generuję pakiet DEB dla wersji 64 bitowej..."
  czysc_katalog
  prepare_control 64
  prepare_changelog
  cp ../../bluray-film-player.linux.64bit ./usr/bin/bluray-film-player
  fakeroot ./debian/rules binary
}


cd bluray-film-player
generuj_all_bit
czysc_katalog
cd ..
cd bluray-film-player-image
prepare_isoimage
generuj_isoimage
czysc_isoimage
cd ..

exit 0
