require 'test_helper'

class GeocolliderTest < Minitest::Test
  def setup
    @geocollider = Object.new
    @geocollider.extend(Geocollider::Parser)
  end

  def test_point_construction
    test_point = Geocollider::Point.new(latitude: 40.714268, longitude: -74.005974)
    test_point_redux = Geocollider::Point.new(longitude: -74.005974, latitude: 40.714268)
    assert_equal(test_point.lat, test_point_redux.lat)
    assert_equal(test_point.lon, test_point_redux.lon)
    test_point_string = Geocollider::Point.new(latitude: "40.714268", longitude: "-74.005974")
    assert_equal(test_point.lat, test_point_string.lat)
    assert_equal(test_point.lon, test_point_string.lon)
  end

  def test_haversine_distance
    assert_equal(0,
                 @geocollider.haversine_distance(
                   Geocollider::Point.new(latitude: 0, longitude: 0),
                   Geocollider::Point.new(latitude: 0, longitude: 0)
                 )
                )
    assert_equal(5837.057346290527,
                 @geocollider.haversine_distance(
                   Geocollider::Point.new(latitude: 40.714268, longitude: -74.005974),
                   Geocollider::Point.new(latitude: 48.856667, longitude: 2.350987)
                 )
                )
  end
end
