#!/bin/sh

cd bluray-film-player-1.0
cp ../../cat_films.linux.32bit ./usr/bin/
cp ../../cat_films.linux.64bit ./usr/bin/
fakeroot ./debian/rules binary

cd debian
rm -r .debhelper
rm -r bluray-film-player
rm bluray-film-player.debhelper.log
rm bluray-film-player.substvars
rm files
rm ../usr/bin/cat_films.linux.32bit
rm ../usr/bin/cat_films.linux.64bit

exit 0
