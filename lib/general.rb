=begin
General - Methods which all install scripts require

Author:  Michael Pope
=end

module General
  def install(pkg)
	puts "Installing #{pkg}..."
	`export DEBIAN_FRONTEND=noninteractive;apt-get install -y #{pkg}`
  end

  def check_line(file,search)
	search_found = false
	File.open(file).each_line do |f|
      f.grep(%r{search}) do |line|
        search_found = true;
      end
	end
  end

  # Download and move to destination
  # Return the file object
  def download(url,dest)
    if File.exists?(dest)
      puts "Destination file '#{dest}' already exists."
    else
      # Download the file
      puts "Downloading #{url}"
      filename=open(url,
                    :progress_proc => lambda{|s|
                      print('.')
                    })

      # If it's a stringIO create a file, otherwise move the file.
      if filename.class.to_s == "StringIO"
        File.open(dest,'w'){|f|
          filename.readlines.map{|line| f.write line}
        }
      else
        File.rename(filename.path,dest)        
      end

      puts "\nMoved download to: #{dest}"
    end

    File.new(dest)
  end
end
