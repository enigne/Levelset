TARGET=domain.pdf transientStraight.pdf transientSemicircle.pdf compareVelShape.pdf compareErrors.pdf compareDist_re1.pdf compareDist_re100.pdf compareVelShape_rectangle.pdf compareMeshres.pdf compareDist_sym_re1.pdf compareDist_sym_re100.pdf symmetric_mesh_errors.pdf sint_vel_200res.pdf compareDist_diag_re1.pdf three_meshes.pdf compareDist_meshrefine.pdf

.PHONY : all finish clean

all: $(TARGET) finish

domain.pdf:  rectangle.pdf semicircle.pdf

%.pdf: %.tex
	pdflatex $^

finish:
	rm -rf *.log *.aux

clean: finish
	rm -rf *.pdf
