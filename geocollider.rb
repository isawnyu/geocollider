#!/usr/bin/env ruby

require_relative 'parsers/pleiades_parser'

pleiades = PleiadesParser.new()
names, places = pleiades.parse(%w{pleiades-places-latest.csv pleiades-names-latest.csv pleiades-locations-latest.csv})
$stderr.puts names.first.inspect
$stderr.puts places.first.inspect
$stderr.puts names.keys.length
$stderr.puts places.keys.length
