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
    'http://github.com/isawnyu/geocollider'
  s.license     = 'MIT'
  s.add_runtime_dependency 'rgeo'
  s.add_runtime_dependency 'rgeo-geojson'
  # s.add_runtime_dependency 'pbf_parser'
  s.add_runtime_dependency 'highline'
  s.add_runtime_dependency 'i18n'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'yard'
end
