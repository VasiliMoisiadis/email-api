lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = 'email_api'
  spec.version = '1.0.0'
  spec.authors = ['Vasili Moisiadis']
  spec.email   = ['vasili@moisiadis.com']

  spec.summary     = 'Email API'
  spec.description = 'Backend Email API that accepts necessary information and sends emails using email service providers'
  spec.homepage    = 'https://github.com/VasiliMoisiadis/email-api'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'Unsupported'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(tests|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'dotenv', '~> 2.2.1'
  spec.add_development_dependency 'json', '~> 2.1.0'
  spec.add_development_dependency 'minitest', '~> 5.11.3'
  spec.add_development_dependency 'minitest-reporters', '~> 1.1.19'
  spec.add_development_dependency 'mocha', '~> 1.4.0'
  spec.add_development_dependency 'puma', '~> 3.11.3'
  spec.add_development_dependency 'rack-test', '~> 0.8.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rest-client', '~> 2.0.2'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-rails', '~> 3.7.2'
  spec.add_development_dependency 'simplecov', '~> 0.16.1'
  spec.add_development_dependency 'sinatra', '~> 2.0.1'
  spec.add_development_dependency 'thin', '~> 1.2.5'
end
