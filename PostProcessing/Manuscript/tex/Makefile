TARGET=domain.pdf transientStraight.pdf transientSemicircle.pdf compareVelShape.pdf compareErrors.pdf compareDist_re1.pdf compareDist_re100.pdf compareVelShape_rectangle.pdf

all: $(TARGET)

domain.pdf:  rectangle.pdf semicircle.pdf

%.pdf: %.tex
	pdflatex $^

clean: 
	rm -rf *.log *.aux *.pdf
