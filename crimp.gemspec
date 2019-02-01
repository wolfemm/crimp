# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'crimp'
  spec.version       = '1.1.0'
  spec.authors       = ['BBC News']
  spec.email         = ['D&ENewsFrameworksTeam@bbc.co.uk']
  spec.summary       = 'Creates an MD5 hash from simple data structures.'
  spec.description   = 'Platform agnostic MD5 hash from simple data structures made of numbers, strings, booleans, nil, arrays or hashes.'
  spec.homepage      = 'https://www.bbc.co.uk/news'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_dependency 'deepsort'
end
