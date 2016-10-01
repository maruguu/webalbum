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
    print "copy #{source}/#{filename} #{destination}/.images\n"
    FileUtils.copy("#{source}/#{filename}", "#{destination}/.images")
  end
  
  def create_thumbnail(path, filename)
    # create thumbnail in ".thumbnails" folder 
    original = Magick::Image.read("#{path}/.images/#{filename}").first
    image = original.resize_to_fill(@thumbnail_width, @thumbnail_height)
    image.write("#{path}/.thumbnails/#{filename}")
  end
  
  def filtering(path, filename)
    original = Magick::Image.read("#{path}/.images/#{filename}").first
    image = original.resize_to_fit(@image_max_width, @image_max_height)
    image.write("#{path}/.images/#{filename}")
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
      copy_file(source, destination, image)
      create_thumbnail(destination, image)
      filtering(destination, image)
    }
    
    fs[:folders].each {|folder|
      export(folder, path, folder[:rpath])
    }
  end
end

