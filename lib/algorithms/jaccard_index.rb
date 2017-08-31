module Jaccard
  class Index
    def self.generate(category1 = [], category2 = [])
      intersection = (category1 & category2).size
      union = (category1 | category2).size

      jaccard_index = intersection.fdiv(union)
      jaccard_index
    end
  end
end
