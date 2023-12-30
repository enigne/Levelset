TARGET=domain.pdf transientStraight.pdf transientSemicircle.pdf compareVelShape.pdf compareErrors.pdf compareDist_re1.pdf compareDist_re100.pdf compareVelShape_rectangle.pdf

.PHONY : all finish clean

all: $(TARGET) finish

domain.pdf:  rectangle.pdf semicircle.pdf

%.pdf: %.tex
	pdflatex $^

finish:
	rm -rf *.log *.aux

clean: finish
	rm -rf *.pdf
