Gem::Specification.new do |s|
  s.name        = 'geocollider'
  s.version     = '0.0.0'
  s.date        = '2016-10-12'
  s.summary     = "Geocollider"
  s.description = "Place data alignment"
  s.authors     = ["Ryan Baumann"]
  s.email       = 'ryan.baumann@gmail.com'
  s.files       = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md)
  s.homepage    =
    'http://github.com/ryanfb/geocollider'
  s.license     = 'MIT'
  s.add_runtime_dependency 'rgeo'
  s.add_runtime_dependency 'rgeo-geojson'
  s.add_runtime_dependency 'pbf_parser'
end
