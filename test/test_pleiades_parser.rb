require 'test_helper'

class TestPleiadesParser < Minitest::Test
  def setup
    @pleiades = Geocollider::PleiadesParser.new()
  end
end
