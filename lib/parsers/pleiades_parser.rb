require 'net/http'
require 'uri'
require 'zlib'
require 'stringio'

class Geocollider::PleiadesParser
  extend Geocollider::Parser

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
      if filename =~ /^pleiades-names-.*\.csv$/
        $stderr.puts "Parsing Pleiades names..."
        CSV.foreach(filename, :headers => true) do |row|
          [row["title"], row["nameAttested"], row["nameTransliterated"]].each do |name|
            normalized_name = string_normalizer(name)
            unless name.nil?
              names[normalized_name] ||= []
              names[normalized_name] |= ["http://pleiades.stoa.org#{row["pid"]}"]
            end
          end
        end
      elsif filename =~ /^pleiades-places-.*\.csv$/
        $stderr.puts "Parsing Pleiades places..."
        CSV.foreach(filename, :headers => true) do |row|
          places["http://pleiades.stoa.org#{row["path"]}"] = row.to_hash
          places["http://pleiades.stoa.org#{row["path"]}"]['point'] = Geocollider::Point.new(latitude: row['reprLat'].to_f, longitude: row['reprLong'].to_f)
        end
      elsif filename =~ /^pleiades-locations-.*\.csv$/
        $stderr.puts "Parsing Pleiades locations..."
      end
    end

    return names, places
  end
end
