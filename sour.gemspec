# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name          = "sour"
  s.authors       = ["Jakub Hozak"]
  s.email         = 'jakub@3scale.net'
  s.description   = %q{Tool for converting comments to Swagger JSON specification}
  s.summary       = %q{Builds a swagger compliant JSON specification from annotations on the comments of your source code.}
  s.homepage      = "https://github.com/HakubJozak/sour.git"
  s.files         = `git ls-files`.split($\)
#  s.executables = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.executables = [ 'sour' ]
  s.extra_rdoc_files = ['README.md']
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  s.version       = '0.1.0'
end
