# Đình công.

## 08 nov. 2022
- Lorsque que je cherche juste "đình công" (grève du travail), google donne principalement des définitions. J'ai donc décidé d'ajouter des mots clés tels que : "ở Pháp" pour "en France","Sài Gòn" ou encore "Hà Nội".

Je dois faire attention car avec "đình công à Hà Nội", google ignore parfois les tons ajoutés et donne des résultats avec  "Định công", un quartier à Hanoi.

## 16 nov. 2022

Les pages vietnamiennes sont encodées en UTF-8, mais certains charactères sont mal encodés. Lorsque je copie une URL, les lettres avec des tons vietnamiens deviennent donc des charactères "interdits" tels que des chiffres ou "@" et le script pour le tableau testé sur mon git personnel ne marche pas.

## 19 dec. 2022

Résumé :

- Certains sites vietnamiens ne permettent pas l'accès aux informations via le script. Ca affiche donc des erreurs 404, par exemple, alors que l'URL existe bien. Je change donc les URLs problématiques.
- Problème de segmentation pour trouver les occurences du mot à cause de l'espace qui n'est pas pris en charge. Il faut que je trouve comment utiliser le tokenizer.
