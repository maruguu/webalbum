# Static Web Album Page Generator
# 
# usage: webalbum.rb <source> <destination> 

require './finder.rb'
require './exporter.rb'
require './generator.rb'

source = ARGV[0]
destination = ARGV[1]
fs = ImageFinder.new(source).result
exporter = Exporter.new
exporter.export(fs, destination)
generator = Generator.new
generator.output(fs, destination)
