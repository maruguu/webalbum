# find images in source folder
require 'FileUtils'

def isImage?(path)
  ext = File.extname(path).downcase
  ext == ".jpg" || ext == ".png" || ext == ".bmp" || ext == ".gif"
end

class ImageFinder
  attr_reader :root
  def initialize(source)
    @root = source || '.'
  end
  
  # return array of image file in source folder
  def findImages(source)
    list = []
    Dir::foreach(source) {|f|
      next if f == "." || f == ".."
      next unless isImage?(f)
      list.push(f)
    }
    list
  end
  
  # return array of folder structure hash
  def findFolders(r_path)
    list = []
    source = @root + r_path
    Dir::foreach(source) {|f|
      next if f == "." || f == ".."
      next if f == ".images" || f == ".thumbnails" # .images and .thumbnails are used as system folder
      path = source + "/" + f
      if FileTest::directory?(path)
        new_r_path = r_path + "/" + f
        imagelist = findImages(path)
        folderlist = findFolders(new_r_path)
        if !(imagelist.empty? && folderlist.empty?)
          list.push ({:root => @root,
                      :rpath => new_r_path, 
                      :images => imagelist, 
                      :folders => folderlist})
        end
      end
    }
    list
  end
  
  def result
    {:root => @root,
     :rpath => "",
     :images => findImages(@root),
     :folders => findFolders("") 
    }
  end
  
  def self.print_structure(folder, level=0)
    level.times { print "  " }
    print folder[:root]
    puts folder[:rpath]
    folder[:images].each {|image|
      (level+1).times { print "  " }
      puts image
    }
    folder[:folders].each {|f|
      self.print_structure(f, level + 1)
    }  
  end
end

# ImageFinder.print_structure(ImageFinder.new(ARGV[0]).result)
