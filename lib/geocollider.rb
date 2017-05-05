require 'csv'
require 'i18n'

module Geocollider
  class Point
    attr_accessor :lat, :lon

    def initialize(args)
      @lat = args[:latitude]
      @lon = args[:longitude]
    end
  end

  # The Geocollider::Parser mixin is designed to be included
  # by individual parser classes.
  module Parser
    # Compute the haversine (great-circle) distance between two
    # Geocollider::Point objects.
    def haversine_distance(point1, point2)
      km_conv = 6371 # km
      dLat = (point2.lat - point1.lat) * Math::PI / 180
      dLon = (point2.lon - point1.lon) * Math::PI / 180
      lat1 = point1.lat * Math::PI / 180
      lat2 = point2.lat * Math::PI / 180

      a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
      d = km_conv * c
    end

    # Check if two Geocollider::Point objects are within a given
    # distance threshold (in kilometers).
    def check_point(point1, point2, distance_threshold = 8.0)
      if haversine_distance(point1, point2) < distance_threshold
        return true
      else
        return false
      end
    end
  end

  # Convenience methods for normalizing strings.
  class StringNormalizer
    attr_reader :input

    def initialize(input)
      @input = input
    end

    # Constructs a string normalizer lambda, given an array of
    # strings matching Geocollider::StringNormalizer instance
    # methods.
    def self.normalizer_lambda(normalizations)
      lambda do |input_string|
        string_normalizer = self.new(input_string)
        # $stderr.puts "Before normalization: #{input_string}"
        %w{case accents nfc punctuation latin whitespace}.each do |normalizer|
          if normalizations.include?(normalizer)
            string_normalizer.send(normalizer)
          end
        end
        # $stderr.puts "After normalization: #{string_normalizer.input}"
        return string_normalizer.input
      end
    end

    # Convert multiple spaces to a single space, strip trailing/leading space.
    def whitespace
      @input = @input.gsub(/\ +/, ' ').strip
    end

    # Normalize to lowercase.
    def case
      @input = @input.downcase
    end

    # Convert to Unicode NFD, then strip accent class characters.
    def accents
      @input = @input.unicode_normalize(:nfd).gsub(/\p{M}/,'')
    end

    # Convert to Unicode Normalized Form C.
    def nfc
      @input = @input.unicode_normalize(:nfc)
    end
      
    # Strip all punctuation class characters.
    def punctuation
      @input = @input.gsub(/\p{P}/u, '')
    end

    # Transliterate all characters to Latin script.
    def latin
      @input = I18n.transliterate(@input)
    end
  end
end

require 'parsers/csv_parser'
require 'parsers/geojson_parser'
require 'parsers/geonames_parser'
require 'parsers/osm_pbf_parser'
require 'parsers/pleiades_parser'
require 'parsers/tgn_parser'
