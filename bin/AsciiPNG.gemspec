Gem::Specification.new do |s|
  s.name        = 'AsciiPNG'
  s.version     = '1.0.0'
  s.date        = '2013-02-23'
  s.summary     = "A Ruby gem to asciify png images."
  s.description = "A Ruby gem to asciify png images."
  s.authors     = ["Tom Van Eyck"]
  s.email       = 'tomvaneyck@gmail.com'
  s.homepage    = 'https://github.com/vaneyckt/asciipng'

  s.add_runtime_dependency 'chunky_png'
  s.add_runtime_dependency 'oily_png'
  s.add_runtime_dependency 'kmeans-clustering'
end
