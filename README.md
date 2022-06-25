# STCC
STCC => Shell To C Converter

Shell script that translates basic shell code to C source code.

Jest to pierwsza wersja skryptu i raczej nie ostatnia.

Opis działania.

# echo "" > Output.c
Ta linia odpowiada za wyzerowanie pliku wyjściowego. 

# input=In.sh
Przekazanie do zmiennej nazwy pliku wejściowego

# TempFile=Buffor 
Przekazanie do zmiennej nazwy pliku tymczasowego
Plik tymczasowy jest po to, by ułatwić sobie edytowanie pliku linia po linii bez używania zmiennych.

# while IFS= read -r line 
Rozpoczęcie czytania pliku wejściowego linia po linii.

# echo "$line" > $TempFile 
Przekazanie linii do Buffora (Pliku tymczasowego)
 
# Edited=0 
Ustalenie wartości Edited na 0 
Wytłumaczenie znaczenia tej zmiennej później
 
# Tłumaczenie Syntaxu

Za przykład posłuży 'case' w języku sh

W if'ie poleceniem "grep" sprawdzamy czy w pliku tymczasowym znajduje się słówko "case", następnie to co zwróciło ów polecenie zostaje przekazane do komendy "wc" z argumentem "-l" który zwróci nam ilość wartość 0 lub 1. ( W pliku tymczasowym może znajdować się tylko jedna linia, przez co wartość zwracana przez "wc -l" może być równa tylko 0 lub 1). Jeśli otrzymamy 1, czyli grep znalazł słówko kluczowe "case" polecenie "sed" wkracza do akcji.

sed -i -e 's/case/switch(/' -e 's/in/){/' $TempFile

Pierwsza część polecenia, czyli " sed -i -e 's/case/switch(/' " zamienia "case" na "switch("

**Przykład**

Przed:
  case $INPUT_STRING in

Po:
  switch( $INPUT_STRING in

Druga część, czyli "-e 's/in/){/'" podmienia "in" na "){"

**Przykład**

Przed:
  switch( $INPUT_STRING in

Po:
  switch( $INPUT_STRING ){

I tym sposobem pierwsze słowo kluczowe zostaje przetłumaczone. 

Edited=1 Służy za oznaczenie linii jako już edytowanej. Dokładniejsze tłumaczenie później.
 
Identycznie robimy z każdą inną znaną nam częścią syntax'a shell'a

# Wielki if i case na końcu

Tu pojawia się znaczenie zmiennej Edited

Jeżeli żaden ze wcześniejszych if'ów nie zmienił nic w pliku, może oznaczać to, iż mamy do czynienia z inicjalizacją zmiennej, komentażem, lub też inną częścią składni o której zapomnieliśmy.

Sh nie ma typu zmiennych, C natomiast niestety takowe posiada, dlatego potrzebny jest sposób na określenie jaki typ ma to być. 

Według mnie nie ma łatwego sposobu na wskazanie programowi jak ma zinterpretować daną zmienną, ponieważ pisząc:

Zmienna='1'

Programista mógł mieć na myśli typ znakowy, ciąg znaków, typ int lub też typ float. Dlatego najłatwiejszym sposobem rozwiązania tego problemu jest zapytanie go o co mu tak na prawdę chodziło. Pierwszy "read" upewnia się, że faktycznie jest to inicjalizacja, a drugi dopytuje o jaki typ chodzi i dopisuje odpowiednie słówko na początku linii. Po wyjściu z if'ów skrypt dopisuje ; o którym w C nie wolno zapomnieć i tak kończy się ów straszny if.

# While

While na samym końcu służy do pozbycia się wszyskich $ z pliku tymczasowego.

# Cat

Przepisuje zmieniony już plik tymczasowy do pliku wyjściowego.

# done

Zakończenie!

