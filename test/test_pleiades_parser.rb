require 'test_helper'

class TestPleiadesParser < Minitest::Test
  def setup
    @pleiades = Geocollider::PleiadesParser.new()
  end

  def test_simple
    assert_equal(1,1)
  end
end
