require_relative "../geocollider_parser"

class GeonamesParser < GeocolliderParser
  def compare(names, places, filenames, csv_writer)
    filenames.each do |filename|
      geonames_csv_string = File.open(filename, "rb").read.force_encoding('UTF-8').encode('UTF-8', :invalid => :replace)
      CSV.parse(geonames_csv_string, :headers => false, :col_sep => "\t", :quote_char => "\u{FFFF}") do |row|
        geoname = {}
        geoname["id"] = row[0]
        geoname["name"] = row[1]
        geoname["asciiname"] = row[2]
        geoname["alternatenames"] = row[3].nil? ? [] : row[3].split(',')
        geoname["latitude"] = row[4].to_f
        geoname["longitude"] = row[5].to_f
        geoname["featureclass"] = row[6]
        geoname["featurecode"] = row[7]
        geonames_names = ([geoname["name"], geoname["asciiname"]] + geoname["alternatenames"]).uniq.compact
        $stderr.puts geonames_names.inspect 
        geonames_names.each do |name|
          $stderr.puts "Checking #{name}"
          if names.keys.include?(name)
            $stderr.puts "Name match, checking places..."
            names[name].each do |place|
              $stderr.puts "Checking #{place}"
              if self.class.check_point(places[place]['point'], Point.new(geoname["latitude"],geoname["longitude"]))
                csv_writer << [place, geoname["id"]]
              end
            end
          end
        end
      end
    end
  end
end
