# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mumukit/auth/version'

Gem::Specification.new do |spec|
  spec.name          = 'mumukit-auth'
  spec.version       = Mumukit::Auth::VERSION
  spec.authors       = ['Franco Leonardo Bulgarelli']
  spec.email         = ['franco@mumuki.org']
  spec.summary       = 'Library for authenticating mumuki requests'
  spec.homepage      = 'http://github.com/mumuki/mumukit-auth'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/**']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 2'


  spec.add_dependency 'jwt'
  spec.add_dependency 'auth0'
  spec.add_dependency 'mumukit-core', '~> 0.4.1'
end
