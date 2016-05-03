special = "?<>',?[]}{=-)(*&^%$#`~{}"
regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/

some_string = "abcdkdienfd ("
puts "true" if some_string =~ regex
