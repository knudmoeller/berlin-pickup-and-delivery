Dir.glob(File.expand_path("match_osm/*.rb", File.dirname(__FILE__))).each do |file|
    require file
end
