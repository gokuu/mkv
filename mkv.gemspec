# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "mkv/version"

Gem::Specification.new do |s|
  s.name        = "mkv"
  s.version     = MKV::VERSION
  s.authors     = ["Pedro Rodrigues"]
  s.email       = ["pedro@bbde.org"]
  s.homepage    = "http://github.com/gokuu/mkv"
  s.summary     = "Reads MKV info."
  s.description = "Simple wrapper around MKVToolNix's mkvinfo utility to get data from MKV movies, and mkvextract to extract subtitles."
  
  s.add_development_dependency("rspec", "~> 2.7")
  s.add_development_dependency("rake", "~> 0.9.2")

  s.files        = Dir.glob("lib/**/*") + %w(README.md LICENSE CHANGELOG)
end