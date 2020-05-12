#! /usr/bin/env ruby

require 'csv'

unless ARGV.length != 4
    csv_in_path = ARGV[0]
    md_out_path = ARGV[1]
    table_header = ARGV[2]
    table_alignment = ARGV[3].split("")

    alignment_mapping = { 'l' => ':---', 'c' => ':---:', 'r' => '---:' }
    alignment_mapping.default = '---'

    File.open(md_out_path, "wb") do |md_out|
        md_out.puts "\#\# #{table_header}"
        md_out.puts

        rows = CSV.read(csv_in_path)

        header_row = rows.shift
        md_out.puts header_row.join(" | ")
        md_out.puts table_alignment.map { |alignment| alignment_mapping[alignment] }.join(" | ")

        rows.each do |row|
            md_out.puts row.join(" | ")
        end

        md_out.puts

    end
    
else
    puts "usage: ruby #{File.basename(__FILE__)} CSV_IN MD_OUT TABLE_HEADER"
end