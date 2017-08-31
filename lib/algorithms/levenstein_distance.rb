module Levenstein
  class Distance
    def self.generate(string1 = "", string2 = "")
      string1_length = string1.length
      string2_length = string2.length

      return string1_length if string2_length == 0
      return string2_length if string1_length == 0

      distance = Array.new(string1_length + 1) { Array.new(string2_length + 1) }

      (0..string1_length).each { |row_index| distance[row_index][0] = row_index }
      (0..string2_length).each { |column_index| distance[0][column_index] = column_index }

      (1..string1_length).each do |row|
        (1..string2_length).each do |column|
          distance[row][column] = if string1[row-1] == string2[column-1]
                                    distance[row-1][column-1]         # no operation
                                  else
                                    [ distance[row-1][column] + 1,    # deletion
                                      distance[row][column-1] + 1,    # insertion
                                      distance[row-1][column-1] + 1,  # substitution
                                    ].min
                                  end
        end
      end

      levenstein_distance = distance[string1_length][string2_length]
      difference_percent = levenstein_distance.fdiv(string2.size)

      [levenstein_distance, difference_percent]
    end
  end
end
