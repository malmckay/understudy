Gem::Specification.new do |gem|
  gem.name     = "understudy"
  gem.version  = "0.0.1"
  gem.date     = "2013-08-01"
  gem.summary  = "A means to tryout new code without side effects"
  gem.email    = "mal@mcommons.com"
  gem.homepage = "http://github.com/mcommons/understudy"
  gem.description = "Understudy runs new code alongside old code, and logs any differences."
  gem.has_rdoc = false
  gem.authors  = ["Mal McKay"]
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
