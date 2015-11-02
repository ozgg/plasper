lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'plasper/version'

Gem::Specification.new do |spec|
  spec.name          = 'plasper'
  spec.version       = Plasper::VERSION
  spec.date          = Plasper::DATE
  spec.summary       = 'Plasper that talks'
  spec.description   = 'Texts generator that analyzes input and tries to imitate syllables'
  spec.authors       = ['Maxim Khan-Magomedov']
  spec.email         = 'maxim.km@gmail.com'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]
  spec.homepage      = 'https://github.com/ozgg/plasper'
  spec.license       = 'MIT'
  spec.has_rdoc      = false
  spec.add_development_dependency "rspec", '~> 3.3'
  spec.add_runtime_dependency 'weighted-select', '~> 1.0.0'
  spec.add_runtime_dependency 'unicode', '~> 0.4.4'
end
