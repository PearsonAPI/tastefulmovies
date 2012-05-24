BINS = ./node_modules/.bin
NIB  = ./node_modules/nib

APP_FILES = \
	base.coffee \
	models.coffee \
	app.coffee \
	router.coffee \
	main.coffee \

APP_DEPS = \
	zepto.js \
	underscore.js \
	backbone.js \
	jade.js \

DEV_BUNDLE = glu/assets/scripts/glu.js
BUNDLE = glu/build/scripts/glu.js

all:
	@rm -rf glu/build; \
	mkdir glu/build; \
	cp -r glu/assets/* glu/build; \
	$(BINS)/stylus -c -u $(NIB) glu/build/styles; \
	echo '' > $(BUNDLE); \
	for f in $(APP_DEPS); do cat glu/build/scripts/$$f >> $(BUNDLE); echo ';' >> $(BUNDLE); done; \
	echo 'Glu = {};' >> $(BUNDLE); \
	echo 'Glu.templates = {};' >> $(BUNDLE); \
	for f in glu/build/scripts/app/templates/*.jade; do \
		name=$$(basename $$f | cut -d'.' -f 1); \
		src=$$($(BINS)/jade -c -D < $$f); \
		echo "Glu.templates['$$name'] = (function(){return $$src; })();" >> $(BUNDLE); \
	done; \
	$(BINS)/coffee -c -p -j noop `for f in $(APP_FILES); do echo glu/build/scripts/app/$$f; done;` >> $(BUNDLE); \
	$(BINS)/uglifyjs -o $(BUNDLE) $(BUNDLE); \
	rm -rf glu/build/styles/*.styl; \
	rm -rf glu/build/scripts/app; \
	for f in $(APP_DEPS); do rm -f glu/build/scripts/$$f; done;

clean: dev-clean
	@rm -rf glu/build

dev: dev-styles dev-bundle

dev-styles:
	@$(BINS)/stylus -c -u $(NIB) glu/assets/styles > /dev/null

dev-templates:
	@DIR=glu/assets/scripts/app/templates; \
	OUT=$$DIR/../$$(basename $$DIR).js; \
	echo 'Glu.templates = {};' > $$OUT; \
	for f in $$DIR/*.jade; do \
		name=$$(basename $$f | cut -d'.' -f 1); \
		src=$$($(BINS)/jade -c -D < $$f); \
		echo "Glu.templates['$$name'] = (function(){return $$src; })();" >> $$OUT; \
	done;

dev-bundle: dev-templates
	@echo 'Glu = {};' > $(DEV_BUNDLE); \
	cat glu/assets/scripts/app/templates.js >> $(DEV_BUNDLE); \
	$(BINS)/coffee -c -p -j noop `for f in $(APP_FILES); do echo glu/assets/scripts/app/$$f; done;` >> $(DEV_BUNDLE)

dev-clean:
	@rm -f glu/assets/scripts/glu.js \
	rm -f `find glu/assets/scripts/app -name "*.js"` \
	rm -f `find glu/assets/styles -name "*.css"`


.PHONY: dev dev-styles dev-templates dev-clean dev-bundle clean
