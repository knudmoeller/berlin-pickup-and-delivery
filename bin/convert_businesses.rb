#! /usr/bin/env ruby

require 'pp'
require_relative "../lib/gastro_schema.rb"

unless ARGV.length != 2

    converter = RestaurantConverter.new(ARGV[0])
    ntriples_out = File.open(ARGV[1], 'wb')
    converter.each do |entry|
        ntriples_out.puts entry
    end
    ntriples_out.close
else
    puts "usage: ruby #{File.basename(__FILE__)} JSON_IN NTRIPLES_OUT"
end