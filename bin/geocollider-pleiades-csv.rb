#!/usr/bin/env ruby

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'geocollider'
require 'highline/import'

pleiades = Geocollider::PleiadesParser.new()
names, places = pleiades.parse(%w{pleiades-places-latest.csv pleiades-names-latest.csv pleiades-locations-latest.csv})
$stderr.puts names.first.inspect
$stderr.puts places.first.inspect
$stderr.puts names.keys.length
$stderr.puts places.keys.length

csv_options = {}

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
csv_options[:names] = ask("What column(s) are your name values in (comma-separated)?  ", lambda { |str| str.split(/,\s*/) } )

$stderr.puts csv_options.inspect

csv_parser = Geocollider::CSVParser.new(csv_options)
CSV.open(ARGV[0], "wb") do |csv|
  csv_compare = csv_parser.comparison_lambda(names, places, csv)
  csv_parser.parse(ARGV[1..-1], csv_compare)
end
