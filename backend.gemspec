
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "backend"
  spec.version       = "1.0.0"
  spec.authors       = ["Vasili Moisiadis"]
  spec.email         = ["vasili@moisiadis.com"]

  spec.summary       = "Siteminder Software Engineering Challenge - Backend"
  spec.description   = "Backend API that accepts necessary information and sends emails using email service providers"
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "dotenv", "~> 2.2.1"
  spec.add_development_dependency "json", "~> 2.1.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rest-client", "~> 2.0.2"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "sinatra", "~> 2.0.1"
  spec.add_development_dependency "thin", "~> 1.2.5"
end
