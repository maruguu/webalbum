# export image files with resize
require 'FileUtils'
require 'RMagick'

class Exporter
  attr_reader :thumbnail_width
  attr_reader :thumbnail_height
  def initialize
    # read yml for configuration
    @thumbnail_width = 160
    @thumbnail_height = 160
    @image_max_width = 480
    @image_max_height = 480
  end
  
  def copy_file(source, destination, filename)
    dstpath = "#{destination}/.images/#{filename}"
    if File.exist?(dstpath)
      print "skip copy #{source}/#{filename}\n"
    else
      print "copy #{source}/#{filename} -> #{dstpath}\n"
      original = Magick::Image.read("#{source}/#{filename}").first
      image = original.resize_to_fit(@image_max_width, @image_max_height)
      image.write(dstpath)
    end
  end
  
  def create_thumbnail(path, filename)
    dstpath = "#{path}/.thumbnails/#{filename}"
    if File.exist?(dstpath)
      print "skip create thumbnail #{dstpath}\n"
    else
      # create thumbnail in ".thumbnails" folder 
      print "create thumbnail to #{dstpath}\n"
      original = Magick::Image.read("#{path}/.images/#{filename}").first
      image = original.resize_to_fill(@thumbnail_width, @thumbnail_height)
      image.write(dstpath)
    end
  end
  
  # export from source folder structure to destination path
  def export(fs, path, rpath = "")
    source = "#{fs[:root]}/#{fs[:rpath]}"
    destination = "#{path}/#{rpath}"
    if not fs[:images].empty?
      FileUtils.mkdir_p(destination) unless Dir.exist?(destination)
      FileUtils.mkdir_p("#{destination}/.images") unless Dir.exist?("#{destination}/.images")
      FileUtils.mkdir_p("#{destination}/.thumbnails") unless Dir.exist?("#{destination}/.thumbnails")
    end
    fs[:images].each{|image|
      next if FileTest::directory?(source + "/" + image)
      copy_file(source, destination, image)
      create_thumbnail(destination, image)
    }
    
    fs[:folders].each {|folder|
      export(folder, path, folder[:rpath])
    }
  end
end

