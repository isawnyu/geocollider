require 'rgeo/geo_json'

class Geocollider::GeoJSONParser
  extend Geocollider::Parser

  def parse(filenames, compare = nil)
    names = {}
    places = {}

    filenames.each do |filename|
      $stderr.puts "Parsing #{filename} as GeoJSON"
      parsed_geojson = RGeo::GeoJSON.decode(File.read(filename), json_parser: :json)
      $stderr.puts parsed_geojson.class.to_s
      if parsed_geojson.class == RGeo::GeoJSON::FeatureCollection
        parsed_geojson.each do |geojson_feature|
          unless compare.nil? 
            %w{name title}.each do |name|
              if geojson_feature.properties.include?(name)
                compare.call(geojson_feature[name], Geocollider::Point.new(geojson_feature.geometry.y, geojson_feature.geometry.x), "#{filename} #{geojson_feature[name]}")
              end
            end
          end
        end
      else
      end
    end
  end

  def comparison_lambda(names, places, csv_writer)
    lambda_function = lambda do |name, place, id|
      if names.has_key?(name)
        $stderr.puts "Name match for #{name}, checking places..."
        names[name].each do |check_place|
          $stderr.puts "Checking #{check_place}"
          if Geocollider::GeoJSONParser.check_point(places[check_place]['point'], place)
            $stderr.puts "Match!"
            csv_writer << [check_place, id]
          end
        end
      end
    end
    return lambda_function
  end
end
