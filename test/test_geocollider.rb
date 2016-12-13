require 'test_helper'

class GeocolliderTest < Minitest::Test
  def setup
    @geocollider = Object.new
    @geocollider.extend(Geocollider::Parser)
  end

  def test_simple
    assert_equal(1,1)
  end

  def test_haversine_distance
    assert_equal(0,@geocollider.haversine_distance(0,0,0,0))
    assert_equal(5837.057346290527,@geocollider.haversine_distance(40.714268,-74.005974,48.856667,2.350987))
  end
end
