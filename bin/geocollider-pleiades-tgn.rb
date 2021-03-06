#!/usr/bin/env ruby
#
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require 'geocollider'

pleiades = Geocollider::Parsers::PleiadesParser.new()
names, places = pleiades.parse(%w{pleiades-places-latest.csv pleiades-names-latest.csv pleiades-locations-latest.csv})
$stderr.puts names.first.inspect
$stderr.puts places.first.inspect
$stderr.puts names.keys.length
$stderr.puts places.keys.length

tgn = Geocollider::Parsers::TGNParser.new()
CSV.open(ARGV[0], "wb") do |csv|
  tgn_comparison = tgn.comparison_lambda(names, places, csv)
  tgn.parse(ARGV[1..-1], tgn_comparison)
end
