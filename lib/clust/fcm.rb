require 'matrix'

# main module

module Clust
  class FCM

    class Point
      attr_reader :point
      attr_accessor :coef

      def initialize point, coef
        @point = Vector.elements [point].flatten
        @coef  = coef
      end

      def u k
        @coef[k]
      end

      def update_u k, center
      end

      def dist point
        Math.sqrt(
          @point.zip(point)
                .map { |x, y| (x - y) ** 2 }
                .sum
        )
      end
    end

    attr_reader :num_of_clust, :points

    def initialize data, num_of_clust, params={}
      @m = params[:m] || 2
      @num_of_clust = num_of_clust
      @points = data.map { |x| Point.new x, randomize }
    end

    def run
      center 0
    end

    private

    def center k
      weights = points.map { |p| p.u(k) ** @m }.sum
      points.map { |p| p.point * (p.u(k) ** @m) }
            .inject(:+) / weights
    end

    def randomize
      sum = 1000.0
      res = []
      (num_of_clust - 1).times do |x| 
        perc = rand sum
        perc = (perc > sum) ? sum : perc
        res << perc
        sum -= perc
      end
      res << sum
      res.map { |x| x / 1000.0 }
    end
  end
end
