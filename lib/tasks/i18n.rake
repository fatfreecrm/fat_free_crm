# add task for getting missed locales for a lang
$KCODE = 'UTF8'
require 'ya2yaml'

namespace :i18n do
  desc "Copy all missing lang identifiers from [src_file].yml to [dest_file].yml"
  task :fill_lang do

    if ENV['src_file'].blank? or ENV['dest_file'].blank?
      puts "Give all parameters: src and dest. " +
        "E.g.: rake i18n:fill_lang src_file='de' dest_file='en' 
        (optional: src_lang and dest_lang if namespace of locales file diff to file name)"
      exit
    end
    src_path = File.join(RAILS_ROOT,'config','locales', "#{ENV['src_file']}.yml")
    dest_path = File.join(RAILS_ROOT,'config','locales', "#{ENV['dest_file']}.yml")

    unless File.readable?(src_path)
      puts "File #{src_path} not readable!"
      exit
    end

    unless File.exist?(dest_path)
      puts "File #{dest_path} does not exist. Creating it..."
      File.new(dest_path, "w")
    end

    # handle file and lang if there is a diff
    if ENV['src_lang'].blank?
      ENV['src_lang'] = ENV['src_file']
    end
    if ENV['dest_lang'].blank?
      ENV['dest_lang'] = ENV['dest_file']
    end

    # We assume that the src file is correct...
    yaml_src = YAML::load_file(src_path)
    struct_src = yaml_src[ENV['src_lang']]

    # ...but the src not necessarily. So, in case, we create a new lang file:
    @yaml_dest = YAML::load_file(dest_path)
    @yaml_dest ||= Hash.new
    @struct_dest = @yaml_dest[ENV['dest_lang']]
    @struct_dest ||= Hash.new

    # merge all unknown changes to the dest struct:
    merge_recursively struct_src

    @yaml_dest[ENV['dest_lang']] = @struct_dest
    File.open(dest_path, "w") do |file|
      file.puts @yaml_dest.ya2yaml
    end

    puts File.new(dest_path).read
    puts "Everything done."
  end

  #
  # SOME HELPER FUNCTIONS
  #
  def merge_recursively(pairs, parents = [])
    pairs.each_pair do |k,v|
      # copy the parents path and add the current element key:
      current_path = Array.new(parents) << k
      if v.is_a?(Hash)
        merge_recursively(v, current_path)
      else
        ensure_yaml_contains(@struct_dest, current_path, v.to_s)
      end
    end
  end

  def ensure_yaml_contains(element, path, val)
    #puts "    ensure_yaml_contains(#{element}, #{path}, #{val})"

    if path.length == 1
      if element[path.first].is_a?(Hash) and not val.blank?
        puts "Hash found instead of key. In favor of '#{val}' '#{element.to_s}' will be deleted!"
        element[path.first] = val
      end
      if element[path.first].nil?
        puts "Missing key '#{path.first}'! Pre-filled for editing with: '#{val}'. element was #{element.class}"
        element[path.first] = val + " [[TODO]]  "
      end
      # if none of these replaced anything - we're fine, the key exists!
      # <img src="http://ideadeployment.de/wp-includes/images/smilies/icon_smile.gif" alt=":-)" class="wp-smiley">
    elsif path.length > 1
      # walk down if possible:
      if element[path.first].is_a?(Hash) and element.has_key?(path.first)
        ensure_yaml_contains(element[path.first], path[1..-1], val)
      else
        # We don't have a hash in the dest file, so we create the hash
        # and fill in all subsequent children:
        element[path.first] = Hash.new
        ensure_yaml_contains(element[path.first], path[1..-1], val)
      end
    else
      puts "REPLACING FAILED"
      # should stop here
    end
  end

end