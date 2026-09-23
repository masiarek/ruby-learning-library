# Exercise 1: find_pair returns the [row, column] of the first cell equal to target,
# leaving both loops the moment it is found, and nil when the value is absent.

def find_pair(matrix, target)
  catch(:found) do
    matrix.each_with_index do |row, r|
      row.each_with_index do |value, c|
        puts "   visiting #{r},#{c} (#{value})"
        throw :found, [r, c] if value == target
      end
    end
    nil
  end
end

matrix = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

puts "1. a value that is present"
puts "   -> #{find_pair(matrix, 5).inspect}"

puts "2. a value that is absent"
puts "   -> #{find_pair(matrix, 42).inspect}"
