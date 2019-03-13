find . -name \*.md -type f -exec pandoc -f markdown -t html -o ../{}.html `basename -s .md {}` \;
