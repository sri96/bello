#Bello is a general purpose code pretty printing and formatting utility. Currently the following
#languages are supported

#1. Matlab

#Authors: Adhithya Rajasekaran, Sri Madhavi Rajasekaran

#License: MIT License

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

  def replace_multiline_comments(input_file_contents,comment_syntax,input_file_path)

    def find_all_matching_indices(input_string,pattern)

      locations = []

      index = input_string.index(pattern)

      while index != nil

        locations << index

        index = input_string.index(pattern,index+1)


      end

      return locations


    end

    def find_file_path(input_path,file_extension)

      extension_remover = input_path.split(file_extension)

      remaining_string = extension_remover[0].reverse

      path_finder = remaining_string.index("\\")

      remaining_string = remaining_string.reverse

      return remaining_string[0...remaining_string.length-path_finder]

    end

    comment_start_and_end = comment_syntax.split(" ")

    multiline_comments = []

    file_contents_as_string = input_file_contents.join

    modified_file_contents = file_contents_as_string.dup

    multiline_comment_counter = 1

    multiline_comments_start = find_all_matching_indices(file_contents_as_string,comment_start_and_end[0])

    multiline_comments_end = find_all_matching_indices(file_contents_as_string,comment_start_and_end[1])

    if multiline_comments_start.length.eql?(multiline_comments_end.length)


      for y in 0...multiline_comments_start.length

        start_of_multiline_comment = multiline_comments_start[y]

        end_of_multiline_comment = multiline_comments_end[y]

        multiline_comment = file_contents_as_string[start_of_multiline_comment..end_of_multiline_comment+2]

        modified_file_contents = modified_file_contents.sub(multiline_comment,"--multiline_comment[#{multiline_comment_counter}]")

        multiline_comment_counter += 1

        multiline_comments << multiline_comment


      end


    end

    temporary_m_file = find_file_path(input_file_path,".m") + "magnifique_temp.m"

    file_id = open(temporary_m_file, 'w')

    file_id.write(modified_file_contents)

    file_id.close()

    line_by_line_contents = read_file_line_by_line(temporary_m_file)

    return line_by_line_contents,multiline_comments,temporary_m_file

  end

  def replace_singleline_comments(input_file_contents,comment_syntax)

    single_line_comments = []

    singleline_comment_counter = 1

    for x in 0...input_file_contents.length

      current_row = input_file_contents[x]

      if current_row.include?(comment_syntax)

        comment_start = current_row.index(comment_syntax)

        comment = current_row[comment_start..-1]

        single_line_comments << comment

        current_row = current_row.gsub(comment,"--single_line_comment[#{singleline_comment_counter}]")

        singleline_comment_counter += 1


      end

      input_file_contents[x] = current_row

    end

    return input_file_contents,single_line_comments

  end

  def add_tabs(input_array,start_index,end_index,tabs_to_be_added)

    for x in start_index..end_index

      current_row = input_array[x]

      if !current_row.eql?("\n")

        input_array[x] = tabs_to_be_added + current_row

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

    matlab_comments = {:single_line => "%", :multiline => "%{ }%"}

    matlab_file_contents = reset_tabs(matlab_file_contents)

    matlab_file_contents,multiline_comments,temp_file = replace_multiline_comments(matlab_file_contents,matlab_comments[:multiline],input_file_path)

    matlab_file_contents,singleline_comments = replace_singleline_comments(matlab_file_contents,matlab_comments[:single_line])

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

      tabs_level = 1

      final_modified_file_contents = add_tabs(final_modified_file_contents,top_most_level+1,matching_level-1,"\t"*tabs_level)

      tabs_level += 1

      start_blocks.delete_at(top_most_level_index)

      end_blocks.delete(matching_level)

    end

    final_modified_file_contents.unshift("%{Pretty Printed and Cleansed Using Bello.Visit http://adhithyan15.github.com/bello to learn more!}%\n\n")

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

