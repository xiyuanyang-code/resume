TEX      := pdflatex
FLAGS    := -interaction=nonstopmode -halt-on-error
OUTDIR   := ./cv
MAIN_EN  := tex/main.tex
MAIN_ZH  := tex/zh.tex

PDF_EN   := $(OUTDIR)/cv_en.pdf
PDF_ZH   := $(OUTDIR)/cv_zh.pdf

# 要清理的扩展名列表
AUX_EXT  := aux log out toc synctex.gz

# 默认目标
all: $(PDF_EN) $(PDF_ZH) clean

$(PDF_EN):
	@mkdir -p $(OUTDIR)
	@echo "Compiling English CV..."
	@$(TEX) $(FLAGS) -output-directory=$(OUTDIR) -jobname=cv_en $(MAIN_EN) 

$(PDF_ZH):
	@mkdir -p $(OUTDIR)
	@echo "Compiling Chinese CV..."
	@xelatex $(FLAGS) -output-directory=$(OUTDIR) -jobname=cv_zh $(MAIN_ZH)

clean:
	@echo "Cleaning auxiliary files..."
	@for ext in $(AUX_EXT); do \
		echo "  - Removing *.$$ext"; \
		find $(OUTDIR) tex cv -type f -name "*.$$ext" -delete; \
	done
	@echo "Cleaning PDFs in tex/ ..."
	@find tex -type f -name "*.pdf" -delete

distclean: clean
	@echo "Removing output PDFs..."
	@rm -f $(PDF_EN) $(PDF_ZH)

silent: FLAGS += > /dev/null
silent: all

debug:
	@mkdir -p $(OUTDIR)
	$(TEX) -output-directory=$(OUTDIR) -jobname=XiyuanYang-Resume $(MAIN_EN)

.PHONY: all clean distclean debug silent
