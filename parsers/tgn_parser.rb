require_relative "../geocollider_parser"

class TGNParser
  extend GeocolliderParser

  def parse(filenames, compare = nil)
    geometries = {}
    points = {}
    labels = {}
    filenames.each do |filename|
      $stderr.puts "Parsing #{filename}..."
      File.foreach(filename) do |line|
        split_line = line.split(' ')
        subject = split_line[0]
        predicate = split_line[1]
        object = split_line[2..-2].join(' ') # handle object with spaces, don't include trailing .
        if predicate == '<http://www.w3.org/2000/01/rdf-schema#label>' #label
          tgn_toponym = object[/"(.+)"/,1]
          unless tgn_toponym.nil?
            tgn_toponym.gsub!(/\\u(.{4})/) {|m| [$1.to_i(16)].pack('U')}
            labels[tgn_toponym] ||= []
            labels[tgn_toponym] << subject
          end
        elsif predicate == '<http://schema.org/latitude>'
          subject.sub!('-geometry>','>')
          geometries[subject] ||= {}
          geometries[subject][:latitude] = object[/"(.+)"/,1].to_f
          if geometries[subject].has_key?(:longitude)
            points[subject] = Point.new(geometries[subject][:latitude],geometries[subject][:longitude])
          end
        elsif predicate == '<http://schema.org/longitude>'
          subject.sub!('-geometry>','>')
          geometries[subject] ||= {}
          geometries[subject][:longitude] = object[/"(.+)"/,1].to_f
          if geometries[subject].has_key?(:latitude)
            points[subject] = Point.new(geometries[subject][:latitude],geometries[subject][:longitude])
          end
        elsif predicate == '<http://vocab.getty.edu/ontology#parentString>'
        end
      end # each line
    end # each file

    unless compare.nil?
      $stderr.puts "Checking for matches..."
      labels.each_key do |label|
        labels[label].each do |tgn_subject|
          if points.has_key?(tgn_subject)
            compare.call(label, points[tgn_subject], tgn_subject)
          end
        end
      end
    end
  end

  def comparison_lambda(names, places, csv_writer)
    lambda_function = lambda do |name, place, id|
      if names.has_key?(name)
        $stderr.puts "Name match for #{name}, checking places..."
        names[name].each do |check_place|
          $stderr.puts "Checking #{check_place}"
          if TGNParser.check_point(places[check_place]['point'], place)
            $stderr.puts "Match!"
            csv_writer << [check_place, id]
          end
        end
      end
    end
    return lambda_function
  end
end # TGNParser
