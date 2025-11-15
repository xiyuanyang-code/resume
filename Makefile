TEX	  := pdflatex
FLAGS	:= -interaction=nonstopmode -halt-on-error
OUTDIR   := build
MAIN_EN  := tex/main.tex
MAIN_ZH  := tex/main_zh.tex

PDF_EN	 := $(OUTDIR)/XiyuanYang-Resume.pdf

# todo add chinese versions for CV
PDF_ZH	 := $(OUTDIR)/cv_zh.pdf

# 默认目标
all: $(PDF_EN)

$(PDF_EN):
	@mkdir -p $(OUTDIR)
	@echo "Compiling English CV..."
	@$(TEX) $(FLAGS) -output-directory=$(OUTDIR) -jobname=XiyuanYang-Resume $(MAIN_EN) > /dev/null

clean:
	@echo "Cleaning auxiliary files..."
	@rm -f "$(OUTDIR)/*.aux $(OUTDIR)/*.log $(OUTDIR)/*.out $(OUTDIR)/*.fls $(OUTDIR)/*.fdb_latexmk"

silent: FLAGS += > /dev/null 2>&1
silent: all

debug:
	@mkdir -p $(OUTDIR)
	$(TEX) -output-directory=$(OUTDIR) -jobname=XiyuanYang-Resume $(MAIN_EN)

.PHONY: all clean distclean debug silent