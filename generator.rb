# Generator class will create HTML
# 

require 'erb'


class Generator
  attr_reader :max_images
  
  def initialize()
    @max_images = 10  
  end
  
  def getImageRangeTo(list, from)
    to = from + @max_images - 1
    to = from + list.size - 1 if list.size < @max_images
    return to
  end

  def getCurrentLink(list, from)
    to = getImageRangeTo(list, from)
    return "images#{from}-#{to}.html"
  end
  
  def getPrevLink(list, from)
    return "" if from < @max_images
    return "images#{from - @max_images}-#{from - 1}.html"
  end

  def getNextLink(list, from)
    current_to = getImageRangeTo(list, from)
    return "" if from + @max_images - 1 > current_to 
    return "" if list.size == current_to
    to = from + @max_images * 2 - 1
    to = from + list.size - 1 if list.size < @max_images * 2
    return "images#{from + @max_images}-#{to}.html"
  end
  
  # create image html from images in source folder.
  # return list of created html files.
  def create_image_html(source, destination, images)
    imagelist = images.dup
    createdlist = []
    image_from = 1
    prev_link = ""
    next_link = ""
    until imagelist.empty?
      filename = getCurrentLink(imagelist, image_from)
      image_title = File.basename(filename, ".*")
      prev_link = getPrevLink(imagelist, image_from)
      next_link = getNextLink(imagelist, image_from)
      image_src = imagelist.shift(@max_images)
      e = ERB.new(File.read("./template/images.html.erb"), nil, '-')
      #puts e.result(binding)
      File.open("#{destination}/#{filename}", "w") { |f|
          f.puts e.result(binding)
      }
      createdlist.push (filename)
      image_from += @max_images
    end
  createdlist
  end
  
  def create_index_html(fs, path, rpath, createdlist, imagelist)
    destination = "#{path}/#{rpath}"
    page_title = rpath
    
    # create html tree
    # parent folder
    
    parent_name = ""
    current_name = ""
    slash_pos = rpath.rindex("/")
    if slash_pos
      parent_name = rpath[0, slash_pos]
      parent_name  = ".." if parent_name.empty?
      current_name = rpath[slash_pos, 256]
    end
    child_folders = createdlist.dup
    printf "#{rpath} : #{parent_name} | #{current_name}\n"
    # create image thumbnail list
    image_src = fs[:images].dup
    image_link = []
    image_src.size.times do |i|
      image_link.push(imagelist[i / @max_images])
    end
    
    e = ERB.new(File.read("./template/index.html.erb"), nil, '-')
    File.open("#{destination}/index.html", "w") { |f|
        f.puts e.result(binding)
    }
      
  end
  
  # return true if html is created including child folder
  def output(fs, path, rpath = "")
    #puts fs
    created = false
    createdlist = []
    # output child html
    fs[:folders].each {|folder|
      created = true if output(folder, path, folder[:rpath])
      createdlist.push(folder[:rpath].slice(rpath.size, folder[:rpath].size)) if created 
    }
    
    source = "#{fs[:root]}/#{fs[:rpath]}"
    destination = "#{path}/#{rpath}"
    # generate imageXX-YY.html
    if not fs[:images].empty?
      print "generate image.html in #{destination}\n"
      imagelist = create_image_html(source, destination, fs[:images])
      created = true
    end
    
    # generate index.html
    if created
      print "generate index.html in #{destination}\n"
      create_index_html(fs, path, rpath, createdlist, imagelist)
    end
    created
  end
end

