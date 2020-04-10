require 'csv'
require 'json'
require 'digest'
require 'logger'
require 'pp'
require 'rdf'
require 'rdf/ntriples'

DS_BASE = "https://daten.berlin.de/ds/"
BUSINESS = RDF::Vocabulary.new(File.join(DS_BASE, "business/"))
ADDRESS = RDF::Vocabulary.new(File.join(DS_BASE, "address/"))
OH_SPEC = RDF::Vocabulary.new(File.join(DS_BASE, "opening-hours/"))
VOCAB_BASE = "https://daten.berlin.de/vocab/"
DELIVERY = RDF::Vocabulary.new(File.join(VOCAB_BASE, "delivery/"))
SCHEMA = RDF::Vocabulary.new("https://schema.org/")
XSD = RDF::Vocabulary.new("http://www.w3.org/2001/XMLSchema#")

TYPE_GASTRO = "Gastronomie (Café, Restaurant, Imbiss, Lebensmittelhandlung, usw.)"
TYPE_BEVERAGE_STORE = "Getränkemarkt"

DAY_MAPPING = {
    "montag" => "Monday" ,
    "dienstag" => "Tuesday" ,
    "mittwoch" => "Wednesday" ,
    "donnerstag" => "Thursday" ,
    "freitag" => "Friday" ,
    "samstag" => "Saturday" ,
    "sonntag" => "Sunday"
}

class RestaurantConverter include Enumerable
    def initialize(json_source)
        @source_data = JSON.parse(File.read(json_source))
    end

    def each(&block)
        @source_data['features']
            .map { |feature| feature['properties']['data'].merge({ "coordinates" => feature['geometry']["coordinates"] })}
            .map { |business| business.map { |k,v| [k, v.instance_of?(String) ? v.strip : v] }.to_h }
            .map { |entry| entry_to_rdf(entry) }
            .each(&block)
    end

    def entry_to_rdf(entry)
        # 1. convert entry to graph
        if entry['id']
            graph = RDF::Graph.new
            business_res = BUSINESS["b_#{entry['id']}"]
            case entry['art']
            when TYPE_GASTRO
                business_type = SCHEMA.FoodEstablishment
            when TYPE_BEVERAGE_STORE
                business_type = SCHEMA.FoodEstablishment
            else
                business_type = SCHEMA.LocalBusiness
            end
            graph << [ business_res, RDF.type, business_type ]
            graph << [ business_res, SCHEMA.name, entry['name'] ]
            graph << [ business_res, SCHEMA.description, RDF::Literal.new(entry['angebot'], :language => :de) ]
            graph << [ business_res, SCHEMA.url, entry['w3'] ] unless entry['w3'].empty?
            graph << [ business_res, SCHEMA.email, entry['mail'] ] unless entry['mail'].empty?
            graph << [ business_res, SCHEMA.telephone, entry['fon']] unless entry['fon'].empty?
            unless entry['strasse_nr'].empty?
                # address_res = ADDRESS["a_#{entry['id']}"]
                address_res = RDF::Node.new
                graph << [ business_res, SCHEMA.address, address_res ]
                graph << [ address_res, RDF.type, SCHEMA.PostalAddress ]
                graph << [ address_res, SCHEMA.addressCountry, "DE" ]
                graph << [ address_res, SCHEMA.addressLocality, "Berlin" ]
                graph << [ address_res, SCHEMA.postalCode, entry['plz'] ]
                graph << [ address_res, SCHEMA.streetAddress, entry['strasse_nr'] ]
            end

            graph << [ business_res, DELIVERY.deliveryPossible, german_true?(entry['lieferung'])]
            unless entry['beschreibung_lieferangebot'].empty?
                graph << [ business_res, DELIVERY.deliveryComment, RDF::Literal.new(entry['beschreibung_lieferangebot'], :language => :de) ]
            end
            
            graph << [ business_res, DELIVERY.pickupPossible, german_true?(entry['selbstabholung'])]
            unless entry['angebot_selbstabholung'].empty?
                graph << [ business_res, DELIVERY.pickupComment, RDF::Literal.new(entry['angebot_selbstabholung'], :language => :de) ]
            end
            
            DAY_MAPPING.keys.each do |day_german|
                opening_hours_array = convert_opening_hours(day_german, entry[day_german])
                opening_hours_array.each do |opening_hours|
                    oh_id = Digest::SHA1.hexdigest(opening_hours.values.join)
                    oh_res = OH_SPEC["oh_#{oh_id}"]
                    graph << [ business_res, SCHEMA.openingHoursSpecification, oh_res ]
                    graph << [ oh_res, RDF.type, SCHEMA.OpeningHoursSpecification ]
                    graph << [ oh_res, SCHEMA.dayOfWeek, SCHEMA[opening_hours[:day]]]
                    graph << [ oh_res, SCHEMA.opens, opening_hours[:opens] ]
                    graph << [ oh_res, SCHEMA.closes, opening_hours[:closes] ]
                end
            end

            geo_res = RDF::Node.new
            graph << [ business_res, SCHEMA.geo, geo_res ]
            graph << [ geo_res, RDF.type, SCHEMA.GeoCoordinates ]
            graph << [ geo_res, SCHEMA.longitude, entry['coordinates'][0] ]
            graph << [ geo_res, SCHEMA.latitude, entry['coordinates'][1] ]

            # 2. serialize entry 
            graph.dump(:ntriples)
        end
    end

    def convert_opening_hours(day_german, range_unparsed)
        structured_opening_hours = []
        if day = DAY_MAPPING[day_german]
            ranges = range_unparsed.split(" & ")
            ranges.each do |range|
                times = range.split("-")
                structured_opening_hours << {
                    :day => day ,
                    :opens => "#{times[0]}:00" ,
                    :closes => "#{times[1]}:00"
                }
            end
        end
        structured_opening_hours
    end

    def german_true?(value)
        value.eql?("WAHR") ? true : false
    end
end