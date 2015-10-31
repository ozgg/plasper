Gem::Specification.new do |s|
  s.name    = 'plasper'
  s.version = Plasler::VERSION
  s.date    = '2015-10-31'
  s.summary = 'Plasper'
  s.description = 'Simple abstract texts generator'
  s.authors = ['Maxim Khan-Magomedov']
  s.email = 'maxim.km@gmail.com'
  s.files = %w(lib/plasper.rb)
  s.homepage = 'https://github.com/ozgg/plasper'
  s.license = 'MIT'
  s.add_development_dependency "rspec", '~> 3.3'
  s.add_runtime_dependency 'weighted-select', '~> 1.0.0'
end
