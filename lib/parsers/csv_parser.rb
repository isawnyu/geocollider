# With CSV headers:
# Geocollider::CSVParser.new(
#   {
#     :separator => ",",
#     :quote_char => '"',
#     :headers => true,
#     :lat => "latitude",
#     :lon => "longitude",
#     :names => ["placename"],
#     :id => "identifier"
#   }
# )
#
# Without CSV headers:
# Geocollider::CSVParser.new(
#   {
#     :separator => "\t",
#     :quote_char => "\u{FFFF}",
#     :headers => false,
#     :lat => 4,
#     :lon => 5,
#     :names => [1,2],
#     :id => 0
#   }
# )

class Geocollider::CSVParser
  extend Geocollider::Parser

  def initialize(options = {})
    @parse_options = options
  end

  def parse(filenames, compare = nil)
    names = {}
    places = {}

    filenames.each do |filename|
      csv_data = File.open(filename, "rb")
      until csv_data.eof()
        csv_string = csv_data.readline.force_encoding('UTF-8').encode('UTF-8', :invalid => :replace)
        CSV.parse(csv_string, :headers => @parse_options[:headers], :col_sep => @parse_options[:separator], :quote_char => @parse_options[:quote_char]) do |row|
          csv_row = {}
          csv_row["id"] = row[@parse_options[:id]]

          csv_row["latitude"] = row[@parse_options[:lat]].to_f
          csv_row["longitude"] = row[@parse_options[:lon]].to_f

          csv_names = @parse_options[:names].map {|name_field| row[name_field]}.uniq.compact
          csv_place = Geocollider::Point.new(csv_row["latitude"], csv_row["longitude"])

          if compare.nil? # no comparison function passed
            csv_names.each do |name|
              names[name] ||= []
              names[name] << csv_row["id"]
            end
            places[csv_row["id"]] = {}
            places[csv_row["id"]]["point"] = csv_place
          else
            csv_names.each do |name|
              compare.call(name, csv_place, csv_row["id"])
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
          if Geocollider::CSVParser.check_point(places[check_place]['point'], place)
            $stderr.puts "Match!"
            csv_writer << [check_place, id]
          end
        end
      end
    end
    return lambda_function
  end
end
