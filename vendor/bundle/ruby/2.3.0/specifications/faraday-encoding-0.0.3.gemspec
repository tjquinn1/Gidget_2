# -*- encoding: utf-8 -*-
# stub: faraday-encoding 0.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "faraday-encoding"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Takayuki Matsubara"]
  s.date = "2016-03-25"
  s.description = "A Faraday Middleware sets body encoding when specified by server."
  s.email = ["takayuki.1229@m3.com"]
  s.homepage = ""
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "A Faraday Middleware sets body encoding when specified by server."

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.7"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<faraday_middleware>, ["~> 0.10"])
      s.add_runtime_dependency(%q<faraday>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.7"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<faraday_middleware>, ["~> 0.10"])
      s.add_dependency(%q<faraday>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.7"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<faraday_middleware>, ["~> 0.10"])
    s.add_dependency(%q<faraday>, [">= 0"])
  end
end
