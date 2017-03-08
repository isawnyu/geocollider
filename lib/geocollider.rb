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

  module Parser
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

    def check_point(point1, point2, distance_threshold = 8.0)
      if haversine_distance(point1, point2) < distance_threshold
        return true
      else
        return false
      end
    end
  end

  class StringNormalizer
    def initialize(input)
      @input = input
    end

    def whitespace
      # convert multiple spaces to a single space, strip trailing/leading space
      @input = @input.gsub(/\ +/, ' ').strip
    end

    def case
      @input = @input.downcase
    end

    def accents
      # convert to NFD then strip accent class characters
      @input = @input.unicode_normalize(:nfd).gsub(/\p{M}/,'')
    end

    def nfc
      # convert to NFC
      @input = @input.unicode_normalize(:nfc)
    end

    def punctuation
      # strip all punctuation class characters
      @input = @input.gsub(/\p{P}/u, '')
    end

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
