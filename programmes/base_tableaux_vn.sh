#!/usr/bin/env bash
#!/home/miniconda3/lib/python3
# -*- coding:utf-8 -*

#===============================================================================
# VOUS DEVEZ MODIFIER CE BLOC DE COMMENTAIRES.
# Ici, on décrit le comportement du programme.
# Indiquez, entre autres, comment on lance le programme et quels sont
# les paramètres.
# La forme est indicative, sentez-vous libres d'en changer !
# Notamment pour quelque chose de plus léger, il n'y a pas de norme en bash.
#===============================================================================



fichier_urls=$1 # le fichier d'URL en entrée
fichier_tableau=$2 # le fichier HTML en sortie

if [[ $# -ne 2 ]]
then
	echo "Ce programme demande exactement trois arguments."
	exit
fi
mot="[Đ/đ]ình_công" # à modifier -fait

echo $fichier_urls;
basename=$(basename -s .txt $fichier_urls)

echo "<html><body>" > $fichier_tableau
echo "<h2>Tableau $basename :</h2>" >> $fichier_tableau
echo "<br/>" >> $fichier_tableau
echo "<table>" >> $fichier_tableau
echo "<tr><th>ligne</th><th>code</th><th>URL</th><th>encodage</th><th>dump_html</th><th>dump_text</th><th>occurrences</th><th>contextes</th><th>concordances</th></tr>" >> $fichier_tableau

lineno=1;
while read -r URL; do

	#récupération des pages web utilisées en format html
	aspirations=$(curl $URL > "./aspirations/$basename-$lineno.html")
	
	echo -e "\tURL : $URL";
	# la façon attendue, sans l'option -w de cURL
	code=$(curl -ILs $URL | grep -e "^HTTP/" | grep -Eo "[0-9]{3}" | tail -n 1)
	charset=$(curl -ILs $URL "./aspirations/$basename-$lineno.html" | grep -Eo "charset=(\w|-)+" | cut -d= -f2 | tail -n 1)

	# autre façon, avec l'option -w de cURL
	# code=$(curl -Ls -o /dev/null -w "%{http_code}" $URL)
	# charset=$(curl -ILs -o /dev/null -w "%{content_type}" $URL | grep -Eo "charset=(\w|-)+" | cut -d= -f2)

	echo -e "\tcode : $code";

	if [[ ! $charset ]]
	then
		echo -e "\tencodage non détecté, on prendra UTF-8 par défaut.";
		charset="UTF-8";
	else
		echo -e "\tencodage : $charset";
	fi

	if [[ $code -eq 200 ]]
	then
		dump=$(lynx -dump -nolist -assume_charset=$charset -display_charset=$charset $URL)
		if [[ $charset -ne "UTF-8" && -n "$dump" ]]
		then
			dump=$(echo $dump | iconv -f $charset -t UTF-8//IGNORE)
			# dump_vn=$(echo "$dump" | python3.9 Tokenizer/Tokenizer_VN.py)
		fi
	else
		echo -e "\tcode différent de 200 utilisation d'un dump vide"
		dump=""
		charset=""
	fi

	# Compte des occurrences 

	echo "$dump" > "./dumps-text/$basename-$lineno.txt"
	dump_vn=$(cat "./dumps-text/$basename-$lineno.txt" | python3.9 Tokenizer/Tokenizer_VN.py > "./dumps-tokenize/$basename-$lineno.txt")

	compte=$(echo $dump_vn | grep -o -i -P "$mot" | wc -l)
	
	# construction du contexte 
	echo "$dump_vn" | grep -P -A2 -B2 $mot  > "./contextes/$basename-$lineno.txt"
	
	# construction des concordances

 	bash programmes/concordance.sh ./dumps-text/$basename-$lineno.txt $mot > ./concordances/$basename-$lineno.html

	echo "<tr><td>$lineno</td><td>$code</td><td><a href=\"$URL\">$URL</a></td><td>$charset</td><td><a href="../aspirations/$basename-$lineno.html">html</a></td><td><a href="../dumps-tokenize/$basename-$lineno.txt">text</a></td><td>$compte</td><td><a href="../contextes/$basename-$lineno.txt">contextes</a></td><td><a href="../concordances/$basename-$lineno.html">concordance</a></td></tr>" >> $fichier_tableau
	echo -e "\t--------------------------------"
	lineno=$((lineno+1));
done < $fichier_urls
echo "</table>" >> $fichier_tableau
echo "</body></html>" >> $fichier_tableau

#dump c'est le contenu récupéré de la page 
#Si le code de l'url est 200 on met une variable vide pour l'abandonner, si code différent de 200 et pas  d'erreurs alors on convertit le fichier 
