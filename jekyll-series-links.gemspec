Gem::Specification.new do |spec|
  spec.name          = "jekyll-series-links"
  spec.version       = "0.1.0"
  spec.authors       = ["Armand Halbert"]
  spec.email         = ["armand.halbert@gmail.com"]
  spec.summary       = "Jekyll plugin for organizing posts into series"
  spec.description   = "A Jekyll plugin that lets blog posts declare membership in a series via front matter and renders navigation links to all parts."
  spec.homepage      = "https://github.com/ahalbert/jekyll-series-links"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.5"

  spec.add_runtime_dependency "jekyll", ">= 3.7", "< 5.0"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
