require 'net/http'
require 'uri'
require 'zlib'
require 'stringio'

class Geocollider::PleiadesParser
  extend Geocollider::Parser

  PLEIADES_HOST = 'https://pleiades.stoa.org'

  FILENAMES = %w{locations names places}.map{|i| "pleiades-#{i}-latest.csv"}

  def initialize
    FILENAMES.each do |filename|
      unless File.exist?(filename)
        download(filename + '.gz')
      end
    end
  end

  def download(filename)
    $stderr.puts(filename)
    uri = URI.parse("http://atlantides.org/downloads/pleiades/dumps/#{filename}")
    response = Net::HTTP.get_response(uri)
    last_modified = Date.httpdate(response['last-modified'])
    gz = Zlib::GzipReader.new(StringIO.new(response.body.to_s))
    output_filename = File.basename(filename, '.gz')
    File.write(output_filename, gz.read)
    FileUtils.touch(output_filename, :mtime => last_modified.to_time)
  end

  def parse(filenames, string_normalizer = lambda {|s| s})
    names = {}
    places = {}

    filenames.each do |filename|
      file_contents = File.open(filename, "rb").read.force_encoding('UTF-8').encode('UTF-8', :invalid => :replace)
      if filename =~ /^pleiades-names-.*\.csv$/
        $stderr.puts "Parsing Pleiades names..."
        CSV.parse(file_contents, :headers => true) do |row|
          [row["title"], row["nameAttested"], row["nameTransliterated"]].each do |name|
            unless name.nil?
              normalized_name = string_normalizer.call(name)
              names[normalized_name] ||= []
              names[normalized_name] |= ["#{PLEIADES_HOST}#{row["pid"]}"]
            end
          end
        end
      elsif filename =~ /^pleiades-places-.*\.csv$/
        $stderr.puts "Parsing Pleiades places..."
        CSV.parse(file_contents, :headers => true) do |row|
          normalized_name = string_normalizer.call(row["title"])
          names[normalized_name] ||= []
          names[normalized_name] |= ["#{PLEIADES_HOST}#{row["path"]}"]
          places["#{PLEIADES_HOST}#{row["path"]}"] ||= {}
          places["#{PLEIADES_HOST}#{row["path"]}"]['locationPrecision'] = row['locationPrecision']
          places["#{PLEIADES_HOST}#{row["path"]}"]['title'] = row['title']
          places["#{PLEIADES_HOST}#{row["path"]}"]['points'] ||= []
          places["#{PLEIADES_HOST}#{row["path"]}"]['points'] << Geocollider::Point.new(latitude: row['reprLat'].to_f, longitude: row['reprLong'].to_f)
        end
      elsif filename =~ /^pleiades-locations-.*\.csv$/
        $stderr.puts "Parsing Pleiades locations..."
        CSV.parse(file_contents, :headers => true) do |row|
          places["#{PLEIADES_HOST}#{row["pid"]}"] ||= {'locationPrecision' => row['locationPrecision']}
          places["#{PLEIADES_HOST}#{row["pid"]}"]['points'] ||= []
          places["#{PLEIADES_HOST}#{row["pid"]}"]['points'] << Geocollider::Point.new(latitude: row['reprLat'].to_f, longitude: row['reprLong'].to_f)
        end
      end
    end

    return names, places
  end
end
