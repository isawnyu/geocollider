require 'test_helper'
require 'fileutils'

class BinScriptsTest < Minitest::Test
  def setup
    Dir.glob(File.join('test','fixtures','pleiades-*-latest.csv')).each do |pleiades_file|
      FileUtils.cp(pleiades_file, '.')
    end
  end

  def teardown
    Dir.glob(File.join('test','fixtures','pleiades-*-latest.csv')).each do |pleiades_file|
      FileUtils.rm(File.basename(pleiades_file))
    end
  end

  def test_pleiades_geojson
    output_filename = 'test-output.csv'
    `bundle exec ./bin/geocollider-pleiades-geojson.rb #{output_filename} test/fixtures/stations.geojson > /dev/null 2>&1`
    assert_equal 0,$?.exitstatus
    assert File.exist?(output_filename)
    output_contents = IO.read(output_filename).chomp
    assert_equal 1,output_contents.split("\n").length
    assert_equal 'https://pleiades.stoa.org/places/109126,test/fixtures/stations.geojson Lutetia',output_contents
    FileUtils.rm(output_filename)
  end

  def test_pleiades_geonames
    output_filename = 'test-output.csv'
    `bundle exec ./bin/geocollider-pleiades-geonames.rb #{output_filename} test/fixtures/geonames-IT-1000.csv > /dev/null 2>&1`
    assert_equal 0,$?.exitstatus
    assert File.exist?(output_filename)
    output_contents = IO.read(output_filename)
    assert_equal 63,output_contents.split("\n").length
    FileUtils.rm(output_filename)
  end

  def test_pleiades_tgn
    output_filename = 'test-output.csv'
    `bundle exec ./bin/geocollider-pleiades-tgn.rb #{output_filename} test/fixtures/tgn-labels-1000.nt test/fixtures/tgn-geometries-1000.nt > /dev/null 2>&1`
    assert_equal 0,$?.exitstatus
    assert File.exist?(output_filename)
    output_contents = IO.read(output_filename).chomp
    assert_equal 1,output_contents.split("\n").length
    assert_equal 'https://pleiades.stoa.org/places/49896,<http://vocab.getty.edu/tgn/7001504>',output_contents
    FileUtils.rm(output_filename)
  end
end
