#!/usr/bin/env ruby

# Very simple script for CSV-CSV point matching

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'geocollider'
require 'highline/import'

if ARGV.length != 3
  $stderr.puts "Usage: #{$0} input1.csv input2.csv output.csv"
  exit 1
end

string_normalizer = Geocollider::StringNormalizer.normalizer_lambda()

csv_options = {
  :string_normalizer => string_normalizer
}

puts ""
puts "Will compare #{ARGV[0]} with #{ARGV[1]} and write results to: #{ARGV[2]}"
puts ""
separator = choose do |menu|
  menu.prompt = "Are your files comma separated or tab separated?  "
  menu.choices(:comma, :tab)
  menu.default = :comma
end

if separator == :comma
  csv_options[:separator] = ","
else
  csv_options[:separator] = "\t"
end

csv_options[:headers] = agree("Do your files have headers? (y/n)  ", true)
csv_options[:quote_char] = ask("What quote character do your files use? (press enter for none)  ") { |q| q.default = "\u{FFFF}" }

csv_options[:lat] = ask("What column are your latitude values in?  ", csv_options[:headers] ? String : Integer)
csv_options[:lon] = ask("What column are your longitude values in?  ", csv_options[:headers] ? String : Integer)
csv_options[:id] = ask("What column are your identifier values in?  ", csv_options[:headers] ? String : Integer)
distance_threshold = ask("What distance threshold would you like to use? (in km) |default: 8|  ", Float) { |q| q.default = 8.0 }
# csv_options[:names] = ask("What column(s) are your name values in (comma-separated)?  ", lambda { |str| str.split(/,\s*/) } )

$stderr.puts "CSV Parse options:"
$stderr.puts csv_options.inspect
$stderr.puts "Distance threshold: #{distance_threshold} km"

csv_parser = Geocollider::Parsers::CSVParser.new(csv_options)
names, places = csv_parser.parse([ARGV[0]])
# $stderr.puts places.inspect
CSV.open(ARGV[2], "wb") do |csv|
  csv_compare = csv_parser.point_comparison_lambda(names, places, csv, distance_threshold)
  csv_parser.parse([ARGV[1]], csv_compare)
end
