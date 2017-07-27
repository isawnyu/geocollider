module Geocollider
  module Parsers
    class GeonamesParser
      extend Geocollider::Parser

      def parse(filenames, compare = nil)
        names = {}
        places = {}

        filenames.each do |filename|
          geonames_data = File.open(filename, "rb")
          until geonames_data.eof()
            geonames_csv_string = geonames_data.readline.force_encoding('UTF-8').encode('UTF-8', :invalid => :replace)
            CSV.parse(geonames_csv_string, :headers => false, :col_sep => "\t", :quote_char => "\u{FFFF}") do |row|
              geoname = {}
              geoname["id"] = "http://sws.geonames.org/#{row[0]}/"
              geoname["name"] = row[1]
              geoname["asciiname"] = row[2]
              geoname["alternatenames"] = row[3].nil? ? [] : row[3].split(',')
              geoname["latitude"] = row[4].to_f
              geoname["longitude"] = row[5].to_f
              geoname["featureclass"] = row[6]
              geoname["featurecode"] = row[7]
              geonames_names = ([geoname["name"], geoname["asciiname"]] + geoname["alternatenames"]).uniq.compact
              geonames_place = Geocollider::Point.new(latitude: geoname["latitude"], longitude: geoname["longitude"])
              if compare.nil? # no comparison function passed
                geonames_names.each do |name|
                  names[name] ||= []
                  names[name] << geoname["id"]
                end
                places[geoname["id"]] = {}
                places[geoname["id"]]["point"] = geonames_place
              else
                geonames_names.each do |name|
                  compare.call(name, geonames_place, geoname["id"])
                end
              end
            end
          end
        end

        return names, places
      end

      def comparison_lambda(names, places, csv_writer)
        lambda_function = lambda do |name, place, id|
          if names.has_key?(name)
            $stderr.puts "Name match for #{name}, checking places..."
            names[name].each do |check_place|
              $stderr.puts "Checking #{check_place}"
              places[check_place]['points'].each do |check_point|
                if Geocollider::Parsers::GeonamesParser.check_point(check_point, place)
                  $stderr.puts "Match!"
                  csv_writer << [check_place, id]
                  break
                end
              end
            end
          end
        end
        return lambda_function
      end
    end
  end
end
