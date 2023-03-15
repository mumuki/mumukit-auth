# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mumukit/auth/version'

Gem::Specification.new do |spec|
  spec.name          = 'mumukit-auth'
  spec.version       = Mumukit::Auth::VERSION
  spec.authors       = ['Franco Leonardo Bulgarelli']
  spec.email         = ['franco@mumuki.org']
  spec.summary       = 'Library for authorizing mumuki requests'
  spec.homepage      = 'http://github.com/mumuki/mumukit-auth'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/**']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.0'


  spec.add_dependency 'jwt', '~> 1.5'
  spec.add_dependency 'mumukit-core', '~> 1.8'

  spec.required_ruby_version = '~> 3.1'
end
