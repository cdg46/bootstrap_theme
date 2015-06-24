#!/bin/bash

##########################################################################
# (c) 2014 Yann BOGDANOVIC <ianbogda@gmail.com>
# All rights reserved
#
# This program is free software : you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# The GNU General Public License can be found at
# http://www.gnu.org/copyleft/gpl.html.
#
# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
##########################################################################

# create new bootstrap them for bootstrap_package
# Check for dependencies
function checkDependency() {
	if ! hash $1 2>&-;
	then
		echo "Failed!"
		echo "This script requires '$1' but it can not be found. Aborting."
		exit 1
	fi
}

echo -n "Checking dependencies..."
checkDependency "sed"
checkDependency "git"
checkDependency "rm"
checkDependency "goog-webfont-dl"
echo "Succeeded."


# Quelques variables
DEPOT_GIT=https://github.com/cdg46
CONF=Configuration/Typoscript
FONTS=Resources/Public/Fonts

# creation du nouveau theme

echo "Creation d'un nouveau theme"
read -p "Nom du theme : " THEME
read -p "Auteur du theme : " AUTEUR
read -p "Email de l'auteur : " EMAIL
read -p "Chemin du fichier variables.less : " VARIABLES
read -p "Quelles google webfont : " GOOG_WEBFONT
echo "Infos sur depot distant"
read -p "URL du depot distant : " URL

# clonage d'un theme vierge
cd ..
git clone $DEPOT_GIT/bootstrap_theme.git bootstrap_$THEME
cd bootstrap_$THEME
git init

# Remplacements qui vont bien
sed -i 's/__TITLE__/Bootstrap $THEME/g' ext_emconf.php
sed -i 's/__DESCRIPTION__/Bootstrap $THEME pour bootstrap_package/g' ext_emconf.php
sed -i 's/__AUTEUR__/$AUTEUR/g' ext_emconf.php
sed -i 's/__EMAIL__/$EMAIL/g' ext_emconf.php

# backendLayouts
sed -i 's/__TITLE__/$THEME/g' Configuration/PageTS/Mod/web_layout.txt

# transformation du fichier variables.less en constants.txt
CONSTANTS=$CONF/constants.txt
cp $VARIABLES $CONF
cp $VARIABLES Resources/Private/Theme/variables.less
# suppression des caracteres non TS
sed -i '/^\/\//d' $CONSTANTS
sed -i '/^$/d' $CONSTANTS
sed -i 's/:/=/g' $CONSTANTS
sed -i 's/;//g' $CONSTANTS
sed -i 's/\/\/.*//g' $CONSTANTS
sed -i 's/[ \t]*$//' $CONSTANTS
sed -i 's/\.\.\/fonts/..\/..\/..\/..\/..\/typo3conf_/ext_/bootstrap_$THEME\/Resources\/Public\/Fonts\//' $CONSTANTS

# recuperation google webfont
WEBFONTS=(${GOOG_WEBFONT//,/ })
for WEBFONT in "${WEBFONTS[@]}"; do
	goog-webfont-dl -a -f "$WEBFONT"
	cat "$WEBFONT.css" >> Resources/Private/Less/Theme/webfont.less
	mv "$WEBFONT/*" Resources/Public/Fonts/
	rm -rf "$WEBFONT"
done
# sed url src
sed -i 's/\.\.\/fonts/@{icon-font-path}/g' Resources/Private/Less/Theme/webfont.less

echo `pwd`
exit 0
git add .
git commit -m "Initial commit"
rm -rf .git
git remote add origin $URL
git push origin master

cd ../bootstrap_$THEME
