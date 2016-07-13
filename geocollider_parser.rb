require 'csv'

class Point
  attr_accessor :lat, :lon

  def initialize(latitude, longitude)
    @lat = latitude
    @lon = longitude
  end
end

class GeocolliderParser
  DISTANCE_THRESHOLD = 8.0

  def self.haversine_distance(lat1, lon1, lat2, lon2)
    km_conv = 6371 # km
    dLat = (lat2-lat1) * Math::PI / 180
    dLon = (lon2-lon1) * Math::PI / 180
    lat1 = lat1 * Math::PI / 180
    lat2 = lat2 * Math::PI / 180

    a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    d = km_conv * c
  end

  def self.check_point(point1, point2)
    if haversine_distance(point1.lat, point1.lon, point2.lat, point2.lon) < DISTANCE_THRESHOLD
      return true
    else
      return false
    end
  end

  def parse(filenames)
    raise "Not implemented!"
  end

  def compare(names, places, filenames, csv_writer)
    raise "Not implemented!"
  end

  def download(filename)
    raise "Not implemented!"
  end
end
