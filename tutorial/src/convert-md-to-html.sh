for i in *.md; do pandoc -f markdown -t html -o ../`basename -s .md $i`.html $i ; done
