#! /usr/bin/env ruby

require 'csv'

unless ARGV.length != 3
    csv_in_path = ARGV[0]
    md_out_path = ARGV[1]
    table_header = ARGV[2]

    File.open(md_out_path, "wb") do |md_out|
        md_out.puts "\#\# #{table_header}"
        md_out.puts

        rows = CSV.read(csv_in_path)

        header_row = rows.shift
        md_out.puts header_row.join(" | ")
        md_out.puts Array.new(header_row.length, "---").join(" | ")

        rows.each do |row|
            md_out.puts row.join(" | ")
        end

        md_out.puts

    end
    
else
    puts "usage: ruby #{File.basename(__FILE__)} CSV_IN MD_OUT TABLE_HEADER"
end