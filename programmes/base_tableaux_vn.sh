#!/usr/bin/env bash
# -*- coding:utf-8 -*

fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie

if [[ $# -ne 2 ]]
then
	echo "Ce programme demande exactement deux arguments." 
	exit
fi

mot="[Đ/đ]ình_công" # L'expression régulière du mot grève en vietnamien.

echo $fichier_urls;
basename=$(basename -s .txt $fichier_urls) # Nom de base des fichiers

# Construction du début du tableau.
echo "<html><body>" > $fichier_tableau
echo "<h2>Tableau $basename :</h2>" >> $fichier_tableau
echo "<br/>" >> $fichier_tableau
echo "<table>" >> $fichier_tableau
echo "<tr><th>Ligne</th> <th>Code</th> <th>URL</th> <th>Encodage</th> <th>Dump HTML</th> <th>Dump text</th> <th>Occurrences</th> <th>Contextes</th><th>Concordances</th></tr>" >> $fichier_tableau

lineno=1;
while read -r URL; do

# Récupération des pages web utilisées en format html
	aspirations=$(curl $URL > "./aspirations/$basename-$lineno.html")
	
	echo -e "\tURL : $URL";
	code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1)
	charset=$(curl -ILs $URL "./aspirations/$basename-$lineno.html" | grep -Eo "charset=(\w|-)+" | cut -d= -f2 | tail -n 1)

	echo -e "\tcode : $code";

# Détection de l'encodage

    if [[ ! $charset ]]
    then
        echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
        charset="UTF-8";
    else
        echo -e "\tencodage : $charset";
    fi

# Code HTML : s'il est de 200 alors on récupère le contenu de la page, sinon on utilise un dump vide.
	if [[ $code -eq 200 ]]
	then
		dump=$(lynx -dump -nolist -assume_charset=$charset -display_charset=$charset $URL)
		if [[ $charset -ne "UTF-8" && -n "$dump" ]]
		then
			dump=$(echo $dump | iconv -f $charset -t UTF-8//IGNORE) # Conversion en UTF-8
			# dump_vn=$(echo "$dump" | python3.9 Tokenizer/Tokenizer_VN.py) Tokenizer qui ne marche pas pour une raison inconnue
		fi
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		charset=""
	fi


# On dump le contenu des pages dans un dossier en format texte.
	echo "$dump" > "./dumps-text/$basename-$lineno.txt" 

# On utilise le tokenizer sur le contenu qui vient d'être dumpé afin que les mots composés soient liés en un seul
# On dump ces nouveaux fichiers dans un autre dossier.

	dump_vn=$(cat "./dumps-text/$basename-$lineno.txt" | python3.9 Tokenizer/Tokenizer_VN.py > "./dumps-tokenize/$basename-$lineno.txt")

# Compte des occurrences

	compte=$(grep -P -o -i $mot "./dumps-tokenize/$basename-$lineno.txt" | wc -l)

# Construction du contexte 

	contexte=$(grep -P -A2 -B2 $mot "./dumps-tokenize/$basename-$lineno.txt"  > "./contextes/$basename-$lineno.txt")
	
# Construction des concordances

 	bash programmes/concordance.sh ./dumps-tokenize/$basename-$lineno.txt $mot > ./concordances/$basename-$lineno.html

# On ferme le tableau
	echo "<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="../aspirations/$basename-$lineno.html">html</a></td><td><a href="../dumps-tokenize/$basename-$lineno.txt">text</a></td><td>$compte</td><td><a href="../contextes/$basename-$lineno.txt">contextes</a></td><td><a href="../concordances/$basename-$lineno.html">concordance</a></td></tr>" >> $fichier_tableau
	echo -e "\t--------------------------------"
	lineno=$((lineno+1));

done < $fichier_urls
echo "</table>" >> $fichier_tableau
echo "</body></html>" >> $fichier_tableau