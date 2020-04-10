Dir.glob(File.expand_path("gastro_schema/*.rb", File.dirname(__FILE__))).each do |file|
    require file
end
