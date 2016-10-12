#!/usr/bin/env ruby
#
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'geocollider'

geonames = Geocollider::GeonamesParser.new()
names, places = geonames.parse([ARGV[0]])
$stderr.puts names.first.inspect
$stderr.puts places.first.inspect
$stderr.puts names.keys.length
$stderr.puts places.keys.length

geojson_parser = Geocollider::GeoJSONParser.new()
CSV.open(ARGV[1], "wb") do |csv|
  geojson_compare = geojson_parser.comparison_lambda(names, places, csv)
  geojson_parser.parse(ARGV[2..-1], geojson_compare)
end
