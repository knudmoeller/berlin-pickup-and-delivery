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

business:b_2
    a schema:FoodEstablishment ;
    delivery:deliveryPossible false ;
    delivery:pickupPossible true ;
    schema:address [
        a schema:PostalAddress ;
        schema:addressCountry "DE" ;
        schema:addressLocality "Berlin" ;
        schema:postalCode "10405" ;
        schema:streetAddress "Strassburgerstraße 16"
    ] ;
    schema:description "Mate Tee & Gemischt Mate Brause boxes zu mitnehmen und trocken Bio Lebensmittel."@de ;
    schema:email "info@metamate.cc" ;
    schema:geo [
        a schema:GeoCoordinates ;
        schema:latitude 52.53064 ;
        schema:longitude 13.41499
    ] ;
    schema:name "Meta Mate" ;
    schema:openingHoursSpecification ohspec:oh_333d9dcb2f35550e0818e0e8081a29b694ec9534, ohspec:oh_3a9d874626ba2de3ee828322bca70c558245ee4e, ohspec:oh_48f4016ca7a6c0a01c3c2fe5e671c77cdb062685, ohspec:oh_8fa5171a0efd7ea719f1acb38b13c59b024272db, ohspec:oh_a13444b8bd03d929e1c32eb7e5b96eaf3a5ef78c ;
    schema:telephone "+4915233738308" ;
    schema:url "https://www.metamate.cc" .

# ...

ohspec:oh_333d9dcb2f35550e0818e0e8081a29b694ec9534
    a schema:OpeningHoursSpecification ;
    schema:closes "18:00:00" ;
    schema:dayOfWeek schema:Friday ;
    schema:opens "12:00:00" .
```

* The local part of the business URI (`b_2`) is minted using the `unique_id` feature of the source data (the `id` field is internal to the SimpleSearch tool used to create the dataset and is not stable between the dataset's versions).
* Each business is either a `schema:FoodEstablishment` or a `schema:LocalBusiness`, based on the source data's `art` field.
* The URIs of the opening hours specification (`ohspec:oh_...`) are a hash over a normalized string of the opening hours for a particular day.
That means that opening hours specifications can be shared by several businesses.
* `business` (namespace for business URIs), `ohspec` (namespace for opening hours specifications) and `delivery` (custom properties not covered by schema.org) are just URI namespaces and don't currently resolve to anything.


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

Last changed: 2020-04-21
