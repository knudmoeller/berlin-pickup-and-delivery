require 'csv'
require 'json'
require "active_support/core_ext"
require 'haversine'
require 'rdf'
require 'rdf/ntriples'
require 'sparql'

require 'pp'


class OSMMatcher

    attr_reader :osm_data

    def initialize(conf)
        @logger = conf[:logger]
        @logger.info("reading OSM JSON file from #{conf[:osm_in]}")
        @osm_data = JSON.parse(File.read(conf[:osm_in]), :symbolize_names => true)
        @logger.info("reading Datenportal graph from #{conf[:datenportal_in]}")
        datenportal_graph = RDF::Graph.load(conf[:datenportal_in])
        @logger.info("query businesses from Datenportal graph")
        @datenportal_data = query_datenportal_graph(datenportal_graph)
        @matches_out = conf[:matches_out]
        @threshold = conf[:threshold]
        known_matches_path = conf[:known_matches]
        @logger.info("query known matches from #{known_matches_path}")
        @known_matches = read_known_matches(known_matches_path)
        @nomatch = []
    end

    def read_known_matches(known_matches_path)
        known_uris = []
        File.open(known_matches_path).each do |statement|
            known_uris << statement.split(" ").first.gsub(/[<>]/,"")
        end
        known_uris
    end

    def query_datenportal_graph(graph)
        query_string = %(
            PREFIX schema: <https://schema.org/>

            SELECT ?place ?name ?lat ?lon
            WHERE {
                ?place
                schema:name ?name ;
                schema:geo ?coords ;
                .

                ?coords 
                schema:latitude ?lat ;
                schema:longitude ?lon ;
            }
        )

        query = SPARQL.parse(query_string)

        datenportal_data = []
        query.execute(graph).each do |solution|
            entry = {}
            solution.each do |predicate, object|
                entry[predicate] = object.to_s
            end 
            datenportal_data << entry
        end
        datenportal_data
    end

    def collect_candidates
        all_candidates = []
        @datenportal_data.each do |dp_entry|
            next if @known_matches.include?(dp_entry[:place])
            @logger.info("collecting candidates for '#{dp_entry[:name]}'")
            dp_location = [ dp_entry[:lat].to_f, dp_entry[:lon].to_f ]
            candidates = []
            @osm_data.each do |osm_entry|
                osm_location = [ osm_entry[:lat].to_f, osm_entry[:lon].to_f ]
                # @logger.info("DP: #{dp_location}, OSM: #{osm_location}")
                distance = Haversine.distance(dp_location, osm_location).to_m
                # we collect all OSM nodes within a distance <= @threshold
                if distance <= @threshold
                    candidates << {
                        :distance => distance ,
                        :osm_id => osm_entry[:id] ,
                        :name => osm_entry[:tags][:name]
                    }
                end
            end
            candidates.sort! { |a,b| a[:distance] <=> b[:distance] }
            all_candidates << {
                :uri => dp_entry[:place] ,
                :name => dp_entry[:name] ,
                :candidates => candidates
            }
        end
        all_candidates
    end

    def select_candidates(all_candidates)
        matches = []
        all_candidates.each do |place|
            @logger.info("looking at candidates for #{place[:uri]} ('#{place[:name]}')")
            if winner = select_candidate(place)
                @logger.info("---> #{winner[:name]} (#{winner[:osm_id]})")
                matches << [ "<#{place[:uri]}>", "<https://daten.berlin.de/vocab/deliveries/osmIdentifier>", "\"#{winner[:osm_id]}\"" , "." ]
            end
        end
        matches
    end

    def select_candidate(place)
        place[:candidates].each do |candidate|
            normalized_datenportal = normalize(place[:name])
            normalized_osm = normalize(candidate[:name])
            next if normalized_osm.empty? || normalized_datenportal.empty?
            # straight match after normalization
            return candidate if normalized_datenportal.eql?(normalized_osm)
            return candidate if normalized_datenportal.include?(normalized_osm) || normalized_osm.include?(normalized_datenportal)
            @nomatch << [ place[:uri].split("_").last, place[:uri], place[:name], candidate[:osm_id], candidate[:name] ]
        end
        return nil
    end

    def normalize(name)
        return name.gsub("&","und").gsub(/[\s\-_"'\.]/,"").parameterize
    end

    def serialize_matches(matches)
        File.open(@matches_out, "wb") do |file|
            matches.each do |match|
                file.puts(match.join(" "))
            end
        end
        CSV.open("data/temp/nomatch.csv", "wb") do |csv|
            csv << [ "datenportal_id", "datenportal_uri", "datenportal_name", "osm_id", "osm_name" ]
            @nomatch.each do |not_a_match|
                csv << not_a_match
            end
        end
    end

end