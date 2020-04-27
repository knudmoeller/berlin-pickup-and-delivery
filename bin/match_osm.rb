#! /usr/bin/env ruby

require 'logger'
require 'pp'
require_relative "../lib/match_osm.rb"

if ARGV.length != 4
    puts "usage: ruby match_osm.rb OSM_SOURCE.json DATENPORTAL_SOURCE.nt MATCHES_OUT.nt KNOWN_MATCHES.nt"
    exit
end

config = {
    :osm_in => ARGV[0] ,
    :datenportal_in => ARGV[1] ,
    :matches_out => ARGV[2] ,
    :known_matches => ARGV[3] ,
    :logger => Logger.new(STDOUT) ,
    :threshold => 100.00
}

matcher = OSMMatcher.new(config)
candidates = matcher.collect_candidates
matches = matcher.select_candidates(candidates)
matcher.serialize_matches(matches)
# pp matcher.osm_data
