require_relative "../geocollider_parser"

class TGNParser
  extend GeocolliderParser

  def compare(names, places, filenames, csv_writer)
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
            if names.has_key?(tgn_toponym)
              labels[tgn_toponym] ||= []
              labels[tgn_toponym] << subject
            end
          end
        elsif predicate == '<http://schema.org/latitude>'
          geometries[subject] ||= {}
          geometries[subject][:latitude] = object[/"(.+)"/,1].to_f
          if geometries[subject].has_key?(:longitude)
            points[subject.sub('-geometry>','>')] = Point.new(geometries[subject][:latitude],geometries[subject][:longitude])
          end
        elsif predicate == '<http://schema.org/longitude>'
          geometries[subject] ||= {}
          geometries[subject][:longitude] = object[/"(.+)"/,1].to_f
          if geometries[subject].has_key?(:latitude)
            points[subject.sub('-geometry>','>')] = Point.new(geometries[subject][:latitude],geometries[subject][:longitude])
          end
        elsif predicate == '<http://vocab.getty.edu/ontology#parentString>'
        end
      end # each line
    end # each file
    $stderr.puts "Checking for matches..."
    matches = {}
    labels.each_key do |label|
      if names.has_key?(label)
        # $stderr.puts "Match: #{label}"
        names[label].each do |place|
          # $stderr.puts labels[label].inspect
          labels[label].each do |tgn_subject|
            if points.has_key?(tgn_subject)
              # $stderr.puts "Checking #{tgn_subject}"
              if self.class.check_point(places[place]['point'],points[tgn_subject])
                unless (matches.has_key?(place) && matches[place].include?(tgn_subject))
                  matches[place] ||= []
                  matches[place] << tgn_subject
                  csv_writer << [place, tgn_subject]
                end
              end
            end
          end
        end
      end
    end
  end # compare
end # TGNParser
