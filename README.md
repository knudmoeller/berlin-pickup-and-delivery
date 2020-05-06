# Delivery and Pickup Services in Berlin

![Logo of "Delivery and Pickup Services in Berlin" dataset](logo/lieferdienste-logo_small.png)

This repository contains RDF data on businesses in Berlin that offer delivery and/or pickup of products.
The data includes restaurants and other food establishments, but also any other kind of business that had to close its doors due to the current Corona/Covid-19 situation, and is now relying on delivery and pickup services.

The RDF data can be found in [data/target/lieferdienste.ttl](data/target/lieferdienste.ttl).

## Format and Vocabulary

The RDF data is serialised as [Turtle](https://www.w3.org/TR/turtle/), mainly using terminology from [schema.org](https://schema.org), as well as some [additional terms](vocab/delivery.ttl) for things not covered by schema.org.

## Source

The data is derived from the GeoJSON version of the dataset [Gastronomien, Laden- und andere Geschäfte mit Liefer- und Abholservice](https://daten.berlin.de/datensaetze/gastronomien-laden-und-andere-geschäfte-mit-liefer-und-abholservice), which is published under [CC BY 3.0 DE](http://creativecommons.org/licenses/by/3.0/de/) by Berlin's [Senate Department for Economics, Energy and Public Enterprises](https://www.berlin.de/sen/wirtschaft/) (Senatsverwaltung für Wirtschaft, Energie und Betriebe).
The data was collected using a Web form by [Technologiestiftung Berlin](https://www.technologiestiftung-berlin.de) (TSB).

## Target

The following is an example of the target data in [Turtle](https://www.w3.org/TR/turtle/) format:

```turtle
@prefix schema: <https://schema.org/> .
@prefix business: <https://daten.berlin.de/ds/business/> .
@prefix ohspec: <https://daten.berlin.de/ds/opening-hours/> .
@prefix delivery: <https://daten.berlin.de/vocab/delivery/> .

business:b_199
    a schema:FoodEstablishment ;
    delivery:deliveryComment "Ab 50€ Bestellwert liefern wir im Umkreis von 4 km"@de ;
    delivery:deliveryPossible true ;
    delivery:osmIdentifier "2109017886" ;
    delivery:pickupComment "Wiener Schnitzel, Saftgulasch, Kässpätzle"@de ;
    delivery:pickupPossible true ;
    schema:address [
        a schema:PostalAddress ;
        schema:addressCountry "DE" ;
        schema:addressLocality "Berlin" ;
        schema:postalCode "10777" ;
        schema:streetAddress "Motzstraße 34"
    ] ;
    schema:description "Wiener Schnitzel, Saftgulasch, Kässpätzle"@de ;
    schema:geo [
        a schema:GeoCoordinates ;
        schema:latitude 52.49753 ;
        schema:longitude 13.34682
    ] ;
    schema:name "Sissi - Restaurant" ;
    schema:openingHoursSpecification ohspec:oh_278e11cdddf2f42726fb2fac4e1111f72ed9017e, ohspec:oh_2c11fbcd2c781fb19a336fea0c88c00747565eb6, ohspec:oh_5de23a8d9c8abdc8b52dbe39e00f75621bfc112f, ohspec:oh_80ce7a5a1350c9e01de2226d594e9b29b5d04b52, ohspec:oh_94af436a280831d1e04578c68a19807e3db1730c, ohspec:oh_c45231a188cdbdfba02e2879d9a62aca1914de58, ohspec:oh_cb784c0fceb5a1bfcd322a81083be00404bfa9ab ;
    schema:telephone "+49302101801" ;
    schema:url "https://sissi-berlin.de" .

# ...

ohspec:oh_278e11cdddf2f42726fb2fac4e1111f72ed9017e
    a schema:OpeningHoursSpecification ;
    schema:closes "20:30:00" ;
    schema:dayOfWeek schema:Tuesday ;
    schema:opens "17:00:00" .
```

* The local part of the business URI (`b_2`) is minted using the `unique_id` feature of the source data (the `id` field is internal to the SimpleSearch tool used to create the dataset and is not stable between the dataset's versions).
* Each business is either a `schema:FoodEstablishment` or a `schema:LocalBusiness`, based on the source data's `art` field.
* The URIs of the opening hours specification (`ohspec:oh_...`) are a hash over a normalized string of the opening hours for a particular day.
That means that opening hours specifications can be shared by several businesses.
* `business` (namespace for business URIs), `ohspec` (namespace for opening hours specifications) and `delivery` (custom properties not covered by schema.org) are just URI namespaces and don't currently resolve to anything.
* `delivery:osmIdentifier` is the OpenStreetMap identifier for this business (see [Matching Businesses to OSM](#matching-businesses-to-osm)).


## Conversion Process

Conversion is driven by the [Makefile](Makefile).

The target Turtle data can be created as follows:

```
make data/target/lieferdienste.ttl
```

This will trigger:

- creating the neccessary folders,
- downloading the source data (to `data/source`),
- converting the source to N-triples (in `data/temp`),
- finding matches between the businesses in the dataset to OpenStreetMap identifiers, and
- converting the intermediate N-triples to Turtle (in `data/target`).

## Matching Businesses to OSM

Many of the businesses in this dataset also have a representation in OpenStreetMap (OSM).
Since OSM is so widely known and used as a reference point in other projects, we try to link to it.
This is done as follows:

- Using the Overpass API, we query OSM for all amenity and shop nodes within the bounding box of Berlin (see [bin/get_osm_nodes.rb](bin/get_osm_nodes.rb)).
- For all business entities in the delivery dataset, we find all OSM nodes that are within a range of 100 metres, using the Haversine formula.
- Why such a wide radius? The geocoder approaches used by the delivery dataset and OSM are quite different, so the same business can often have coordinates that are up to 100 metres apart in both sources.
- Starting with the closest OSM match, we then compare the names of the business A with the name of the potential match B.
- A complete match (of the normalized name) will be accepted straight away.
- If no complete match is found, we check if A is contained in B or vice versa (to match things like `Pizzaria da Mario` and `Da Mario`).
- Some manual matches have been included as well.
- There is a lot of room for improvement here, obviously, but the result is good enough for now.  

## Requirements

- The main conversion script [bin/convert_businesses.rb](bin/convert_businesses.rb) is written in Ruby (>=2.4) and requires the [linkeddata](https://rubygems.org/gems/linkeddata) gem, as well as the [uuid](https://rubygems.org/gems/uuid) gem.
- For the matching to OpenStreetMap, the [haversine](https://rubygems.org/gems/haversine) and [overpass-api-ruby](https://rubygems.org/gems/overpass-api-ruby) gems are needed.
- The script to convert the intermedia N-Triples file to Turtle ([bin/to_ttl.sh](bin/to_ttl.sh)) is a simple shell script and requires the `rapper` command to be available. `rapper` is part of [Redland](http://librdf.org). For Mac OS, there is a [brew formula to install Redland](https://formulae.brew.sh/formula/redland). There are also packages for Debian and other distributions.
- [jq](https://stedolan.github.io/jq/) is required for handling intermediate JSON files.

## Logo

- "truck" logo by [FontAwesome](https://fontawesome.com) under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
- "RDF" logo by  [W3C](https://www.w3.org/RDF/icons/).

## License

All software in this repository is published under the [MIT License](LICENSE). All data in this repository is published under [CC BY 3.0 DE](https://creativecommons.org/licenses/by/3.0/de/).


---

2020, Knud Möller, [BerlinOnline Stadtportal GmbH & Co. KG](https://www.berlinonline.net)

Repository: https://github.com/knudmoeller/berlin-pickup-and-delivery

Last changed: 2020-05-06
