TEX      := pdflatex
FLAGS    := -interaction=nonstopmode -halt-on-error
OUTDIR   := ./cv
MAIN_EN  := tex/main.tex
MAIN_ZH  := tex/zh.tex

PDF_EN   := $(OUTDIR)/cv_en.pdf
PDF_ZH   := $(OUTDIR)/cv_zh.pdf

# 要清理的扩展名列表
AUX_EXT  := aux log out toc synctex.gz

# 默认目标：只编译英文版（中文版仅本地维护，产物不入库）
all: $(PDF_EN) clean

$(PDF_EN):
	@mkdir -p $(OUTDIR)
	@echo "Compiling English CV..."
	@$(TEX) $(FLAGS) -output-directory=$(OUTDIR) -jobname=cv_en $(MAIN_EN) 

# 中文版不在默认构建里：本地需要时手动 make zh（强制重编，产物不入库）
zh:
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
	@find tex -type f -name "*.pdf" -not -path "tex/assets/*" -delete

distclean: clean
	@echo "Removing output PDFs..."
	@rm -f $(PDF_EN) $(PDF_ZH)

silent: FLAGS += > /dev/null
silent: all

debug:
	@mkdir -p $(OUTDIR)
	$(TEX) -output-directory=$(OUTDIR) -jobname=XiyuanYang-Resume $(MAIN_EN)

.PHONY: all zh clean distclean debug silent
