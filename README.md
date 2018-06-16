# cat_films
System budowania prywatnych zestawów filmów na płytach Bluray itp.

Można użyć tego programu do utworzenia zestawu filmów na płycie BD-R i podobnych,
bądź płytach DVD-R i tak dalej. Jeśli płyty te mają być odtwrzane na różnych systemach,
warto program skompilować na różne systemy i architektury. Skonfiguruj sobie
IDE Lazarusa tak, by można było to zrobić przynajmniej na i386 i amd64 w linuksie,
oraz win32, opcjonalnie win64.

Zastanów się następnie nad sposobem uruchamiania tak wykonanych płyt.
Na systemach Windows wystarczy zbudować autorun.inf, pod linuksami to nie zadziała.

W systemach linuksowych można dodać informację o tym, by skopiować odpowiedni plik wykonywalny,
nadać mu prawa i uruchomić, program jeśli nie wykryje bazy z danymi w katalogu z którego został
uruchomiony, zacznie skanować zamontowane płyty optyczne i gdy na niej wykryje taki zestaw,
automatycznie go uruchomi. To zadziała prawidłowo, gdy pierwsza taka zamontowana płyta
będzie tą właściwą, lecz gdy będziesz w posiadaniu dwóch napędów i w pierwszym będzie
zamontowany jakiś dysk, zaś dopiero w drugiej ta oczekiwana przez program, nie zostanie
ona znaleziona i program wyświetli odpowiedni komunikat błędu. W takim wypadku lepiej jest
zbudować odpowiedni pakiet ze skryptem dodającym opcję bezpośrednio do menu montowania urządzeń
w systemie. Wtedy po włożeniu płyty, przy montowaniu dostaniesz opcję uruchomienia programu,
który od razu zajrzy tam, gdzie odpowiednie dane się znajdują. Płyta zaczyta odpowiednie informacje
i wykona program dając możliwość dalszego wyboru. Oczywiście można też poinformować program
przez dodanie odpowiedniej opcji, ale to już pozostawiam twojemu wyboru i preferencjom.

Przykładowy pakiet DEB w Debianie możesz zbudować za pomocą załączonego skryptu Alien.
Oczywiście odpowiednie pakietu i zależności muszą być zainstalowane. Skrypt domyślnie oczekuje
na wejściu dwóch wersji plików wykonywalnych pod architektury i396 i amd64, wedle potrzeby
możesz to zmienić w swoich projektach, bądź rozbudować to.


Opis funkcji:

1. Program może pracować w trybie tylko do odczytu, jak również z możliwością zapisu.

Zapis przydaje się w czasie budowania i konfigurowania zestawu, w takim wypadku jest on zapisany
na dysku twardym w którymś katalogu i możesz do projektu dodawać, edytować bądź usuwać wpisy.
Istnieje możliwość pokazywania menu z dodatkowymi narzędziami, opcje przydają się i to bardzo.
Gdzieś dalej w tym dokumencie znajdziesz krótki kurs utworzenia takiego projektu.
Po stworzeniu projektu, przetestowaniu go, można go później ustawić w tyb tylko do odczytu,
wyłaczyć pokazywanie dodatkowych narzędzi. Po dodaniu dodatkowych plików autostartujących,
tj. pliku autorun.inf, czy udostępnieniu plików wykonywalnych, pakietów deb i wypalić na płycie
i mamy gotową płyte multiledialną, która będzie prawidłowo ładować się w systemie.
Wykonanie programu z parametrem --help wyświetli podstawowe komendy.

