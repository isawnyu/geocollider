class Geocollider::PleiadesParser
  extend Geocollider::Parser

  def parse(filenames)
    names = {}
    places = {}

    filenames.each do |filename|
      if filename =~ /^pleiades-names-.*\.csv$/
        $stderr.puts "Parsing Pleiades names..."
        CSV.foreach(filename, :headers => true) do |row|
          [row["title"], row["nameAttested"], row["nameTransliterated"]].each do |name|
            unless name.nil?
              names[name] ||= []
              names[name] |= ["http://pleiades.stoa.org#{row["pid"]}"]
            end
          end
        end
      elsif filename =~ /^pleiades-places-.*\.csv$/
        $stderr.puts "Parsing Pleiades places..."
        CSV.foreach(filename, :headers => true) do |row|
          places["http://pleiades.stoa.org#{row["path"]}"] = row.to_hash
          places["http://pleiades.stoa.org#{row["path"]}"]['point'] = Geocollider::Point.new(row['reprLat'].to_f,row['reprLong'].to_f)
        end
      elsif filename =~ /^pleiades-locations-.*\.csv$/
        $stderr.puts "Parsing Pleiades locations..."
      end
    end

    return names, places
  end
end
