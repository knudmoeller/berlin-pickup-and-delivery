#! /usr/bin/env ruby

require 'uri'

unless ARGV.length != 3
    namespace_file = ARGV[0]
    text_in_path = ARGV[1]
    text_out_path = ARGV[2]

    require(namespace_file)

    File.open(text_out_path, "wb") do |text_out|
        File.open(text_in_path).each do |line|
            uris = URI.extract(line)
            NAMESPACES.each_pair do |namespace, prefix|
                uris.each do |uri|
                    if uri.start_with?(namespace)
                        name = uri.split(namespace)[1]
                        line.gsub!(uri, "[#{prefix}:#{name}](#{uri})")
                    end
                end
            end
            text_out.puts line
        end
    end
else
    puts "usage: ruby #{File.basename(__FILE__)} NAMESPACE_DEF TEXT_IN TEXT_OUT"
end