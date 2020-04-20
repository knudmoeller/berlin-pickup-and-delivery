all: clean data/target/lieferdienste.ttl README.md

data/target/lieferdienste.ttl: data/temp/lieferdienste.nt | data/target
	@echo "converting $< to Turtle ..."
	@echo "writing to $@ ..."
	@bin/to_ttl.sh $< $@

data/temp/lieferdienste.nt: data/source/lieferdienste_simple_search.geojson data/source/lieferdienste_simple_search.csv | data/temp
	@echo "converting $< to N-Triples ..."
	@echo "writing to $@ ..."
	@ruby bin/convert_businesses.rb $< $@

.PHONY: data/source/lieferdienste_simple_search.csv
data/source/lieferdienste_simple_search.csv: | data/source
	@echo "downloading CSV source from SimpleSearch API ..."
	@echo "writing to $@ ..."
	@curl -s "https://www.berlin.de/sen/web/service/liefer-und-abholdienste/index.php/index/all.csv?q=" --output $@

.PHONY: data/source/lieferdienste_simple_search.geojson
data/source/lieferdienste_simple_search.geojson: | data/source
	@echo "downloading GeoJSON source from SimpleSearch API ..."
	@echo "writing to $@ ..."
	@curl -s "https://www.berlin.de/sen/web/service/liefer-und-abholdienste/index.php/index/all.gjson?q=" --output $@

.PHONY: data/temp/date.txt
data/temp/date.txt: | data/temp
	@echo "write current date ..."
	@date "+Last changed: %Y-%m-%d" > $@

clean: clean-source clean-temp clean-target
	@echo "deleting data folder ..."
	@rm -rf data

clean-source:
	@echo "deleting source folder ..."
	@rm -rf data/source

clean-temp:
	@echo "deleting temp folder ..."
	@rm -rf data/temp

clean-target:
	@echo "deleting target folder ..."
	@rm -rf data/target

data/source:
	@echo "creating source directory ..."
	@mkdir -p data/source

data/temp:
	@echo "creating temp directory ..."
	@mkdir -p data/temp

data/target:
	@echo "creating target directory ..."
	@mkdir -p data/target

README.md: data/temp/date.txt
	@echo "update $@ with current date"
	@sed '$$ d' $@ > _README.md
	@cat _README.md $< > $@
	@rm _README.md $<
