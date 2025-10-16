DOC = pandoc

.PHONY: ALL_MD all install view clean

all: ALL_MD README.pdf x_team_rules.pdf x_team_style.pdf

install: 
	sudo apt-get install pandoc 	# run only once

ALL_MD:
	$(DOC) *.md > all_`basename $(CURDIR)`.html

view:
	xdg-open README.pdf		

README.pdf : README.md
	$(DOC) --variable urlcolor=RubineRed README.md -s -o README.pdf

x_team_rules.pdf : x_team_rules.md
	$(DOC) --variable urlcolor=RubineRed x_team_rules.md -s -o x_team_rules.pdf

x_team_style.pdf : x_team_style_guide.md
	$(DOC) --variable urlcolor=RubineRed x_team_style_guide.md -s -o x_team_style.pdf

clean:
	\rm -f *.pdf
	\rm -f *.html
