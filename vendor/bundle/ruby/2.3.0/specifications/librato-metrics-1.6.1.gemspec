# -*- encoding: utf-8 -*-
# stub: librato-metrics 1.6.1 ruby lib

Gem::Specification.new do |s|
  s.name = "librato-metrics"
  s.version = "1.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Matt Sanders"]
  s.cert_chain = ["certs/librato-public.pem"]
  s.date = "2016-03-15"
  s.description = "An easy to use ruby wrapper for Librato's Metrics API"
  s.email = "matt@librato.com"
  s.extra_rdoc_files = ["LICENSE"]
  s.files = ["LICENSE"]
  s.homepage = "https://github.com/librato/librato-metrics"
  s.licenses = ["BSD 3-clause"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.rubygems_version = "2.5.1"
  s.summary = "Ruby wrapper for Librato's Metrics API"

  s.installed_by_version = "2.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, ["~> 0.7"])
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_runtime_dependency(%q<aggregate>, ["~> 0.2.2"])
    else
      s.add_dependency(%q<faraday>, ["~> 0.7"])
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<aggregate>, ["~> 0.2.2"])
    end
  else
    s.add_dependency(%q<faraday>, ["~> 0.7"])
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<aggregate>, ["~> 0.2.2"])
  end
end
