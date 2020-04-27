require 'overpass_api_ruby'
require 'json'

if ARGV.count != 2
    puts "usage: ruby get_osm_nodes.rb TYPE OUT_PATH"
    exit
end

type = ARGV[0].to_sym
outpath = ARGV[1]

# amenity types taken from https://wiki.openstreetmap.org/wiki/Key:amenity
queries = {
    :amenity => {
        :whitelist => [
            "cafe" ,
            "fast_food" ,
            "food_court" ,
            "ice_cream" ,
            "restaurant" ,
            "library" ,
            "toy_library" ,
            "pharmacy" ,
        ]
    } ,
    :shop => {
        :whitelist => nil
    }
}

options = {
    # bounding box for Berlin
    :bbox => {
        :n => 52.6697240587 ,
        :w => 13.0882097323 ,
        :s => 52.3418234221 ,
        :e => 13.7606105539
    } ,
    :timeout => 900,
    :maxsize => 1073741824
}

overpass = OverpassAPI::QL.new(options)

config = queries[type]
query = "node['#{type}']['name'];(._;>;);out body;"
response = overpass.query(query)
nodes = response[:elements]
if config[:whitelist]
    nodes.select! { |node| config[:whitelist].include?(node[:tags][type]) }
end

json_data = JSON.generate(nodes)

out = File.open(outpath, "wb")
out.puts json_data
out.close
