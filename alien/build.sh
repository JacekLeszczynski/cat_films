#!/bin/bash

VER=`../cat_films.linux.64bit --ver`
DATE=`date`
echo "Generowana wersja pakietów to: $VER"
cd bluray-film-player

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
  rm -f ../usr/bin/cat_films
  rm -f ../usr/bin/cat_films.linux.32bit
  rm -f ../usr/bin/cat_films.linux.64bit
  cd ..
}

generuj_control() {
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

generuj_changelog() {
  echo "bluray-film-player ($VER) experimental; urgency=low" > debian/changelog
  echo "" >> debian/changelog
  echo "  * Prepared by alien version 8.95" >> debian/changelog
  echo "  " >> debian/changelog
  echo "" >> debian/changelog
  echo " -- Jacek Leszczyński <sam@bialan.pl>  $DATE" >> debian/changelog
}

generuj_postinst() {
  echo '#!/bin/sh' >debian/postinst
  echo '' >>debian/postinst
  echo 'set -e' >>debian/postinst
  echo '' >>debian/postinst
  echo 'if [ "$1" = configure ]; then' >>debian/postinst
  echo '' >>debian/postinst
  echo '  AR=$(arch)' >>debian/postinst
  echo '  if [ "$AR" = "x86_64" ]; then' >>debian/postinst
  echo '    ln -s /usr/bin/cat_films.linux.64bit /usr/bin/cat_films' >>debian/postinst
  echo '  else' >>debian/postinst
  echo '    ln -s /usr/bin/cat_films.linux.32bit /usr/bin/cat_films' >>debian/postinst
  echo '  fi' >>debian/postinst
  echo '' >>debian/postinst
  echo 'fi' >>debian/postinst
  echo '' >>debian/postinst
  echo 'exit 0' >>debian/postinst
  echo '' >>debian/postinst
}

generuj_prerm() {
  echo '#!/bin/sh' > debian/prerm
  echo 'set -e' >> debian/prerm
  echo '# Automatically added by dh_installinit/11.2.1' >> debian/prerm
  echo 'rm -f /usr/bin/cat_films' >> debian/prerm
  echo '# End automatically added section' >> debian/prerm
}

generuj_all_bit() {
  echo "Generuję pakiet DEB dla wszystkich architektur..."
  czysc_katalog
  generuj_control 0
  generuj_changelog
  generuj_postinst
  generuj_prerm
  cp ../../cat_films.linux.32bit ./usr/bin/
  cp ../../cat_films.linux.64bit ./usr/bin/
  fakeroot ./debian/rules binary
}

generuj_32bit() {
  echo "Generuję pakiet DEB dla wersji 32 bitowej..."
  czysc_katalog
  generuj_control 32
  generuj_changelog
  cp ../../cat_films.linux.32bit ./usr/bin/cat_films
  fakeroot ./debian/rules binary
}

generuj_64bit() {
  echo "Generuję pakiet DEB dla wersji 64 bitowej..."
  czysc_katalog
  generuj_control 64
  generuj_changelog
  cp ../../cat_films.linux.64bit ./usr/bin/cat_films
  fakeroot ./debian/rules binary
}

generuj_all_bit
#generuj_32bit
#generuj_64bit
czysc_katalog

exit 0
