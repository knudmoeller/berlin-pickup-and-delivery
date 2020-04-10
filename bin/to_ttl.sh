#!/bin/bash

rapper -i ntriples -o turtle $1 \
  -f 'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"' \
  -f 'xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"' \
  -f 'xmlns:xsd="http://www.w3.org/2001/XMLSchema#"' \
  -f 'xmlns:owl="http://www.w3.org/2002/07/owl#"' \
  -f 'xmlns:prov="http://www.w3.org/ns/prov#"' \
  -f 'xmlns:skos="http://www.w3.org/2004/02/skos/core#"' \
  -f 'xmlns:dc="http://purl.org/dc/elements/1.1/"' \
  -f 'xmlns:foaf="http://xmlns.com/foaf/0.1/"' \
  -f 'xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#"' \
  -f 'xmlns:wikidata="http://www.wikidata.org/entity/"' \
  -f 'xmlns:schema="https://schema.org/"' \
  -f 'xmlns:business="https://daten.berlin.de/ds/business/"' \
  -f 'xmlns:address="https://daten.berlin.de/ds/address/"' \
  -f 'xmlns:ohspec="https://daten.berlin.de/ds/opening-hours/"' \
  -f 'xmlns:delivery="https://daten.berlin.de/vocab/delivery/"' \
  > $2
