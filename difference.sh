#!/bin/bash

# erstellt von pn17317 (Jesse Wetli)
# 2023-09
# Parameter: file1 und file2
# ein Bash script um dateien zeile für zeile zu vergleichen

# Eingabe der Files
echo 'Type the name of your first file'

read file1

echo 'Type the name of your second file'

read file2

# Überprüfen, ob file1 existiert
if [[ ! -f "$file1" ]]; then
    echo "Datei $file1 existiert nicht."
    exit 1
fi

# Überprüfen, ob file2 existiert
if [[ ! -f "$file2" ]]; then
    echo "Datei $file2 existiert nicht."
    exit 1
fi

# Überprüfen ob die Files gleich lang sind
# Vielleicht noch >&2

anzZeilen1=$(wc -l < "$file1")
anzZeilen2=$(wc -l < "$file2")

if [[ anzZeilen1 -ne anzZeilen2 ]]; then
    echo "--------------------------------" | tee -a log.txt
    echo "$file1 hat nicht gleich viele zeilen wie $file2" | tee -a log.txt
    echo "--------------------------------" | tee -a log.txt
fi

echo $(tail -c1 "$file1")

# Überprüfen ob leere Linien am ende der Files sind
if ! IFS= read -r -n1 -d '' _ < <(tail -c1 "$file1"); then
    echo "" >> "$file1"
fi

if ! IFS= read -r -n1 -d '' _ < <(tail -c1 "$file2"); then
    echo "" >> "$file2"
fi


# Durch jede Zeile in beiden Dateien gehen
# Hier wird auch noch der Dateideskriptor 3 benutzt, welcher dazu da ist um zwei verschiedene Files zu öffnen
# Wenn das zweite File geöffnet wird, dann wird dieser Data Stream dem Dateideskriptor 3 zugewiesen
while IFS= read -r line1 && IFS= read -r line2 <&3; do
  line_number=$((line_number+1))

  if [[ "$line1" == "$line2" ]]; then
    echo "Zeile $line_number ist gleich." | tee -a log.txt
    echo "--------------------------------" | tee -a log.txt
  else
    echo "Zeile $line_number ist unterschiedlich." | tee -a log.txt
    echo "$file1: $line1" | tee -a log.txt | tee -a log.txt
    echo "$file2: $line2" | tee -a log.txt | tee -a log.txt
    echo "--------------------------------" | tee -a log.txt
  fi
done <"$file1" 3<"$file2"