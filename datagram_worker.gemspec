# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datagram_worker/version'

Gem::Specification.new do |spec|
  spec.name          = "datagram_worker"
  spec.version       = DatagramWorker::VERSION
  spec.authors       = ["svs"]
  spec.email         = ["svs@svs.io"]
  spec.summary       = %q{Makes creating datagram workers a cinch}
  spec.homepage      = "http://github.com/svs/datagram_workers"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry-byebug"

  spec.add_dependency "bunny"
end
