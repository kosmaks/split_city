module Clust
  class FCM
    class Point
      def initialize data, num_of_clusters
        @num_of_clusters = num_of_clusters
        @data = data
        @coef = randomize
      end

      private

      def randomize
        sum = 1000.0
        res = []
        @num_of_clusters.times do |x| 
          perc = rand sum
          perc = (perc > sum or x == @num_of_clusters) ? sum : perc
          res << perc
          sum -= perc
        end
        res.map { |x| x / 1000.0 }
      end
    end

    def self.run
      [Point.new([1, 2, 3], 10)]
    end
  end
end
