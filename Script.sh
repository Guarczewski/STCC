#!/bin/sh

#Program tłumaczy podstawowe elementy składni shell na język C
#Skrypt jednak nie jest w stanie poprawnie przetłumaczyć
#Komendy "read" oraz nie jest w stanie poprawnie wyświetlać zmiennych

#Zerowanie pliku wyjściowego
echo "" > Output.c

input=In.sh
TempFile=Buffor

while IFS= read -r line
do

	echo "$line" > $TempFile

	Edited=0

	#Slip pustych lini
	if [ "$line" = "" ]; then
		Edited=1
	fi

	#Tłumaczenie pierwszej linii
	if [ `grep '/bin/sh' $TempFile | wc -l` -eq 1 ]; then
		echo "#include <stdio.h>" > $TempFile
		echo "void main() {" >> $TempFile
		Edited=1
	fi

	#Tłumaczenie switch'a
	if [ `grep case $TempFile | wc -l` -eq 1 ]; then
		sed -i -e 's/case/switch(/' -e 's/in/){/' $TempFile
		Edited=1
	fi

	#Tłumaczenie case i break
	if [ `grep \;\; $TempFile | wc -l` -eq 1 ]; then

		if [ `grep '*)' $TempFile | wc -l` -eq 1 ]; then
			sed -i 's/\*)/default:/' $TempFile
		else
			sed -i -e 's/)/:/' -e 's/^/case /' $TempFile
		fi

		sed -i 's/;;$/ break;/' $TempFile
		Edited=1
	fi

	#Tłumaczenie printf
	if [ `grep 'echo' $TempFile | wc -l` -eq 1 ]; then
		sed -i 's/echo/printf/' $TempFile
		sed -i -e 's/"/(/' -e 's/"/);/' $TempFile
		sed -i -e 's/(/("/' -e 's/)/")/' $TempFile
		Edited=1
	fi

	#Tłumaczenie działań
	if [ `grep expr $TempFile | wc -l` -eq 1 ]; then
		sed -i -e 's/`expr//' -e 's/`/;/' $TempFile
		Edited=1
	fi

	#Tłumaczenie warunków
	sed -i -e 's/-eq/=/' -e 's/-gt/>/' -e 's/-lt/</' $TempFile

	#Tłumaczenie if
	if [ `grep if $TempFile | wc -l` -eq 1 ]; then
		sed -i -e 's/\[/(/' -e 's/];/)/' $TempFile
		sed -i  's/then/{/' $TempFile
		Edited=1
	fi

	#Tłumaczenie else
	if [ `grep else $TempFile | wc -l` -eq 1 ]; then
		sed -i 's/else/}else/' $TempFile
		Edited=1
	fi

	#Tłumaczenie elif
	if [ `grep elif $TempFile | wc -l` -eq 1 ]; then
		sed -i 's/elif/}else if/' $TempFile
		sed -i -e 's/\[/(/' -e 's/];/)/' $TempFile
		sed -i 's/then/{/' $TempFile
		Edited=1
	fi

	#Tłumaczenie while
	if [ `grep while $TempFile | wc -l` -eq 1 ]; then
		sed -i -e 's/\[/(/' -e 's/]/)/' $TempFile
		Edited=1
	fi

	#Tłumaczenie done
	if [ `grep done $TempFile | wc -l` -eq 1 ]; then
		sed -i 's/done/}/' $TempFile
		Edited=1
	fi

	#Tłumacznie do
	if [ `grep do $TempFile | wc -l` -eq 1 ]; then
		sed -i 's/do/{/' $TempFile
		Edited=1
	fi

	#Tłumacznie fi
	if [ `grep fi $TempFile | wc -l` -eq 1 ]; then
		sed -i 's/fi/}/' $TempFile
		Edited=1
	fi

	#Tłumaczenie esac
	if [ `grep esac $TempFile | wc -l` -eq 1 ]; then
		sed -i 's/esac/}/' $TempFile
		Edited=1
	fi

	#"Tłumaczenie" read
	if [ `grep read $TempFile | wc -l` -eq 1 ]; then
		sed -i 's/read/scanf_c/' $TempFile
		sed -i  's/^/\/\//' $TempFile
		Edited=1
	fi

	if [ $Edited -eq 0 ]; then
		cat $TempFile

		echo "Czy ta linia odpowiada za inicjalizacje zmiennej?"
		read -p "| 1 - Tak | 2 - Nie |" Zelect </dev/tty

		case $Zelect in
			1)
			echo "Podaj typ zmiennej."
			echo "I - int"
			echo "F - float"
			echo "D - double"
			echo "C - char"
			read -p "Podaj znak: " SubSelect </dev/tty

			case $SubSelect in
				I) sed -i 's/^/int /' $TempFile;;
				F) sed -i 's/^/float /' $TempFile;;
				D) sed -i 's/^/double /' $TempFile;;
				C) sed -i 's/^/char /' $TempFile;;
			esac ;;
		2)
			echo "Nie udało się przetłumaczyć kodu."
			echo "Linia zostanie zakomentowana."
			sed -i 's/^/\/\//' $TempFile;;
		esac

		sed -i 's/$/;/' $TempFile
	fi


        # Pozbycie się $ z linii
	while [ $(grep '\$' $TempFile | wc -l) -gt 0  ]; do
		sed -i 's/\$//' $TempFile
	done


	cat $TempFile >> Output.c

done < $input

	echo "Program zakończył swoją pracę."
	echo "Przetłumaczony kod znajduje się w Output.c"
	echo "Przed kompilowaniem kodu, manualnie dokonaj zmian"
	echo "w części kodu która nie została przetłumaczona przez skrypt"

