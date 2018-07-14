Do użytkowników systemu Linux:

Linuks nie pozwala uruchamiać programów bezpośrednio z płyty.
Należy więc wykonać jeden z poniższych kroków:


1. zaleca się instalację najnowszej wersji programu z internetu, aby to zrobić,
   wykonaj poniższe dwie linijki:

   # curl -s https://packagecloud.io/install/repositories/repozytorium_jacka/debian/script.deb.sh | bash
   # apt install bluray-film-player


2. możesz także zainstalować pakiet dostępny na płycie: bluray-film-player_x.x.x-x_all.deb
   który jest dołączony do płyty wykonując:

   # dpkg -i [nazwa pakietu]

   i jeśli wystąpią błędy, to jeszcze:

   # apt -f install


3. przegraj plik wykonywalny na dysk twardy, nadaj mu prawa wykonywalności
   i wykonaj program z parametrem:

   $ chmod +x [nazwa pliku]
   $ bluray-film-player --force-dir [ścieżka do napędu optycznego]

