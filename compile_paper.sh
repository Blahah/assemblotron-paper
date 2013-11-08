# generate figures
/code/produce_figures.R

# compile markdown to PDF
pandoc -s -S \
--biblio references/references.bib \
--csl chicago-author-date.csl \
paper.md \
-o paper.pdf
