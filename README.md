# Delivery and Pickup Services in Berlin

![Logo of "Delivery and Pickup Services in Berlin" dataset](logo/lieferdienste-logo_small.png)

This repository contains RDF data on businesses in Berlin that offer delivery and/or pickup of products.
This includes restaurants and other food establishments, but also any other kind of business that had to close its doors due to the current Corona/Covid-19 situation, and is now relying on delivery and pickup services.

The RDF data can be found in [data/target/lieferdienste.ttl](data/target/lieferdienste.ttl).

## Format and Vocabulary

The RDF data is serialised as [Turtle](https://www.w3.org/TR/turtle/), mainly using terminology from [schema.org](https://schema.org), as well as some [additional terms](vocab/delivery.ttl) for things not covered by schema.org.

## Source

The data is derived from the GeoJSON version of the dataset [Gastronomien, Laden- und andere Geschäfte mit Liefer- und Abholservice](https://daten.berlin.de/datensaetze/gastronomien-laden-und-andere-geschäfte-mit-liefer-und-abholservice), which is published under [CC BY 3.0 DE](http://creativecommons.org/licenses/by/3.0/de/) by Berlin's [Senate Department for Economics, Energy and Public Enterprises](https://www.berlin.de/sen/wirtschaft/) (Senatsverwaltung für Wirtschaft, Energie und Betriebe).
The data was collected using a Web form by [Technologiestiftung Berlin](https://www.technologiestiftung-berlin.de) (TSB).

## Conversion Process

Conversion is driven my the [Makefile](Makefile).

The target Turtle data can be created as follows:

```
make data/target/lieferdienste.ttl
```

This will trigger:

- creating the neccessary folders
- downloading the source data (to `data/source`)
- converting the source to N-triples (in `data/temp`)
- converting the intermediate N-triples to Turtle (in `data/target`).

## Requirements

- The main conversion script [bin/convert_businesses.rb](bin/convert_businesses.rb) is written in Ruby (>=2.4) and requires the [linkeddata](https://rubygems.org/gems/linkeddata) gem.
- The script to convert the intermedia N-Triples file to Turtle ([bin/to_ttl.sh](bin/to_ttl.sh)) is a simple shell script and requires the `rapper` command to be available. `rapper` is part of [Redland](http://librdf.org). For Mac OS, there is a [brew formula to install Redland](https://formulae.brew.sh/formula/redland). There are also packages for Debian and other distributions.

## Logo

- "truck" logo by [FontAwesome](https://fontawesome.com) under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
- "RDF" logo by  [W3C](https://www.w3.org/RDF/icons/).

## License

All software in this repository is published under the [MIT License](LICENSE). All data in this repository is published under [CC BY 3.0 DE](https://creativecommons.org/licenses/by/3.0/de/).


---

2020, Knud Möller, [BerlinOnline Stadtportal GmbH & Co. KG](https://www.berlinonline.net)

Last changed: 2020-04-19
