OUTPUT=MATTHEW_GILBERT

help:
	@echo 'Makefile for generating output                                         '
	@echo '                                                                       '
	@echo 'Usage:                                                                 '
	@echo '   make clean                 Remove packaged output                   '
	@echo '   make pdf                   Generate Description.pdf file            '
	@echo '   make package               Package output                           '

clean:
	rm -rf $(OUTPUT) $(OUTPUT).zip description/Description.pdf

pdf:
	cd description && pdflatex Description.tex

package: clean pdf
	mkdir $(OUTPUT)
	cp code/*.m $(OUTPUT)
	cp code/*.xlsx $(OUTPUT)
	cp description/Description.pdf $(OUTPUT)
	zip -r $(OUTPUT).zip $(OUTPUT)
	rm -rf $(OUTPUT)

.PHONY: package clean pdf
