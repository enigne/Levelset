TARGET=domain.pdf compareFrontShape.pdf

all: $(TARGET)

domain.pdf:  rectangle.pdf semicircle.pdf

%.pdf: %.tex
	pdflatex $^

clean: 
	rm -rf *.log *.aux *.pdf
