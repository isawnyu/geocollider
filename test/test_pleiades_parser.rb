require 'test_helper'

class TestPleiadesParser < Minitest::Test
  def setup
    @pleiades = Geocollider::Parsers::PleiadesParser.new()
  end
end
