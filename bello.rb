#Bello is a general purpose code pretty printing and formatting utility. Currently the following
#languages are supported

#1. Matlab

#Authors: Adhithya Rajasekaran, Sri Madhavi Rajasekaran

#License: MIT License

require 'optparse'

def make_it_pretty(input_file_path)

  def read_file_line_by_line(input_path)

    file_id = open(input_path)

    file_line_by_line = file_id.readlines()

    file_id.close

    return file_line_by_line

  end

  def find_file_extension(input_path)

    extension_start = input_path.index(".")

    return input_path[extension_start..-1]

  end

  def reset_tabs(input_file_contents)

    #This method removes all the predefined tabs to avoid problems in
    #later parts of the beautifying process.

    for x in 0...input_file_contents.length

      current_row = input_file_contents[x]

      if !current_row.eql?("\n")

        current_row = current_row.lstrip

      end

      input_file_contents[x] = current_row


    end

    return input_file_contents

  end

  def add_tabs(input_array,start_index,end_index)
    
    for x in start_index..end_index

      current_row = input_array[x]

      if !current_row.eql?("\n")

        input_array[x] = "\t" + current_row

      end

    end

    return input_array

  end

  if find_file_extension(input_file_path).eql?(".m")

    #Matlab is the very first language that was promised under the Matlab-Pretty-Printer project.
    #But the project was abandoned due to time shortage.But that project is now integrated into the Magnifique
    #project.

    matlab_file_contents = read_file_line_by_line(input_file_path)

    matlab_file_contents << "end\n"

    matlab_file_contents = reset_tabs(matlab_file_contents)

    end_locations = []

    key_word_locations = []

    start_blocks = []

    end_blocks = []

    matlab_regexp = /(if |for |function |while |switch )/

    for x in 0...matlab_file_contents.length

      current_row = matlab_file_contents[x]

      if current_row.index(matlab_regexp) != nil

        key_word_locations << x


      elsif current_row.include?("end\n")

        end_locations << x


      end


    end

    modified_file_contents = matlab_file_contents.dup

    for y in 0...end_locations.length

      current_location = end_locations[y]

      current_string = modified_file_contents[current_location]

      finder_location = current_location

      while current_string.index(matlab_regexp) == nil

        finder_location -= 1

        current_string = modified_file_contents[finder_location]

      end

      code_block_begin = finder_location

      code_block_end = current_location

      start_blocks << code_block_begin

      end_blocks << code_block_end

      code_block_begin_string_split = modified_file_contents[code_block_begin].split(" ")

      code_block_begin_string_split[0] = code_block_begin_string_split[0].reverse

      code_block_begin_string = code_block_begin_string_split.join(" ")

      modified_file_contents[code_block_begin] = code_block_begin_string


    end

    final_modified_file_contents = matlab_file_contents.dup
    
    while start_blocks.length != 0

      top_most_level = start_blocks.min

      top_most_level_index = start_blocks.index(top_most_level)

      matching_level = end_blocks[top_most_level_index]
      
      final_modified_file_contents = add_tabs(final_modified_file_contents,top_most_level+1,matching_level-1)
      
      start_blocks.delete_at(top_most_level_index)

      end_blocks.delete(matching_level)

    end

    final_modified_file_contents[-1] = ""
    
    file_id = open(input_file_path,"w")

    file_id.write(final_modified_file_contents.join)

    file_id.close()

    puts "Pretty Printing Succeeded!"

  end


end

options = {}

OptionParser.new do |opts|
  opts.banner = "Usage: bello [options] file_name"

  opts.on("-p", "--pretty FILE", "Format the code beautifully") do |file|
    current_directory = Dir.pwd
    file_path = current_directory + "/" + file
    make_it_pretty(file_path)

  end

end.parse!

