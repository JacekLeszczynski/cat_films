#!/bin/sh

VER=`../cat_films.linux.64bit --ver`
echo "Generowana wersja pakietów to: $VER"

czysc_katalog() {
  echo "Czyszczę katalogi..."
  cd debian
  rm -f -r .debhelper
  rm -f -r bluray-film-player
  rm -f bluray-film-player.debhelper.log
  rm -f bluray-film-player.substvars
  rm -f files
  rm -f ../usr/bin/cat_films.linux.32bit
  rm -f ../usr/bin/cat_films.linux.64bit
  cd ..
}

generuj_64bit() {
  echo "Generuję pakiet DEB dla wersji 64 bitowej..."
  cd bluray-film-player-1.0
  cp ../../cat_films.linux.32bit ./usr/bin/
  cp ../../cat_films.linux.64bit ./usr/bin/
  fakeroot ./debian/rules binary
  cd ..
}

generuj_64bit
czysc_katalog

exit 0
