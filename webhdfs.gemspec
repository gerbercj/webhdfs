# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webhdfs/version'

Gem::Specification.new do |spec|
  spec.name          = "webhdfs"
  spec.version       = Webhdfs::VERSION
  spec.authors       = ["Chris Gerber"]
  spec.email         = ["chris@theGerb.com"]
  spec.description   = %q{Manipulate a remote WebHDFS file system}
  spec.summary       = %q{Manipluate a remote WebHDFS file system}
  spec.homepage      = "http://github.com/gerbercj/webhdfs"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "net/http"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
