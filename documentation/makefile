PYTHON3 = python3
PYTHON2 = python2
MKDOCS = mkdocs
MFILES = ../plot/plot_paropt.md \
../plot/plot_proj.md \
../plot/plot_weight.md \
../cfg_defaults.md \
../misc/generate_data.md \
../res_defaults.md \
../examples/example_simulation.md \
../examples/example_smri.md \
../examples/example_fmri.md \
../fileio/cleanup_files.md \
../set_path.md \
../util/update_dir.md

mfiledir = docs/mfiles

$(info mfiledir is $(mfiledir))


build-mfiles: $(MFILES)

%.md: %.m matdoc.py matdocparser.py
	$(info $(@))
	$(info $(@D))
	mkdir -p $(mfiledir)
	$(PYTHON2) ./matdoc.py "$(<)" > "$(mfiledir)/$(notdir $(@))"

serve: mkdocs.yml
	$(MKDOCS) serve

build: mkdocs.yml
	ENABLE_PDF_EXPORT=1 $(MKDOCS) build

build-demo:
	pandoc docs/full_demo.md --resource-path docs --filter pandoc-fignos --filter pandoc-tablenos --highlight-style tango -o demo/full_demo.pdf 	
	pandoc docs/full_demo.md --resource-path docs --highlight-style tango -o demo/full_demo.docx

