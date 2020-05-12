all: clean data/target/lieferdienste.ttl README.md

data/target/lieferdienste.ttl: data/temp/all.nt | data/target
	@echo "converting $< to Turtle ..."
	@echo "writing to $@ ..."
	@bin/to_ttl.sh $< $@

data/temp/void_description.nt: data/manual/void_description.ttl | data/temp
	@echo "convert $< to N-Triples ..."
	@echo "writing to $@ ..."
	@rapper -i turtle $< > $@

data/temp/all.nt: data/temp/lieferdienste.nt data/manual/known_matches.nt data/temp/void_description.nt data/temp/modified.nt | data/temp
	@echo "combining temporary N-Triples files ($^) ..."
	@echo "writing to $@ ..."
	@cat $^ > $@

data/temp/lieferdienste.nt: data/source/lieferdienste_simple_search.geojson data/source/lieferdienste_simple_search.csv | data/temp
	@echo "converting $< to N-Triples ..."
	@echo "writing to $@ ..."
	@ruby bin/convert_businesses.rb $< $@

data/temp/berlin_amenity.json: | data/temp
	@echo "extracting amenity nodes from OpenStreetMap ..."
	@echo "writing to $@ ..."
	@ruby bin/get_osm_nodes.rb amenity $@

data/temp/berlin_shop.json: | data/temp
	@echo "extracting shop nodes from OpenStreetMap ..."
	@echo "writing to $@ ..."
	@ruby bin/get_osm_nodes.rb shop $@

data/temp/berlin_all.json: data/temp/berlin_amenity.json data/temp/berlin_shop.json | data/temp
	@echo "combining extracted amenity and shop nodes ..."
	@echo "writing to $@ ..."
	@jq -s '[.[][]]' data/temp/*.json > $@

data/temp/matches.nt: data/temp/berlin_all.json data/temp/lieferdienste.nt | data/temp
	@echo "trying to find matches between Datenportal and OSM ..."
	@echo "writing to $@ ..."
	@ruby bin/match_osm.rb data/temp/berlin_all.json data/temp/lieferdienste.nt $@ data/manual/known_matches.nt
	@echo "done - to use the matches, you need to copy them over to data/manual/known_matches.nt ..."

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

.PHONY: data/temp/modified.nt
data/temp/modified.nt: | data/temp
	@echo "write current date as N-Triples to $@ ..."
	@date '+<https://daten.berlin.de/ds/delivery_and_pickup/> <http://purl.org/dc/terms/modified> "%Y-%m-%d"^^<http://www.w3.org/2001/XMLSchema#date> .' > $@

.PHONY: data/temp/type_stats.csv
data/temp/type_stats.csv: data/temp/all+types.nt queries/count_types.rq
	@echo "query $< for type counts ..."
	@echo "writing to $@ ..."
	@arq --data $< --query $(word 2,$^) --results=CSV > $@

data/temp/all+types.nt: data/temp/all.nt data/manual/schema_org_types.nt
	@echo "combining $^ ..."
	@echo "writing to $@ ..."
	@cat $^ > $@

data/temp/type_stats.md: data/temp/type_stats.csv
	@echo "generating markdown table from csv in $< ..."
	@echo "writing to $@ ..."
	@ruby bin/csv_2_md_table.rb $< $@ "Type Statistics" "llr"

.PHONY: data/temp/date.txt
data/temp/date.txt: | data/temp
	@echo "write current date ..."
	@date "+Last changed: %Y-%m-%d" > $@

clean: clean-source clean-temp clean-target

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

README.md: README/main.md data/temp/type_stats.md README/license.md data/temp/date.txt
	@echo "combine parts to generate $@ ..."
	@cat $^ > $@