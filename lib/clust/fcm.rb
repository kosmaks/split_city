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
    end

    attr_reader :num_of_clust, :points

    def initialize data, num_of_clust, params={}
      @m = params[:m] || 2
      @e = params[:e] || 1e-4
      @mpower = 2 / (@m - 1)
      @num_of_clust = num_of_clust
      @points = data.map { |x| Point.new x, randomize }
    end

    def run

      while true do
        oldcoef = @points.map(&:coef).flatten
        normalize
        newcoef = @points.map(&:coef).flatten
        err = newcoef.zip(oldcoef).map { |x, y| (x - y).abs }.max
        break if err <= @e
      end

      @points.map(&:coef)
    end

    def normalize
      centers = current_centers
      @points.each do |p|
        @num_of_clust.times do |k|
          p.coef[k] = 1 / @num_of_clust.times.map do |j|
            ((centers[k] - p.point).r / 
             (centers[j] - p.point).r) ** @mpower
          end.sum
        end
      end
    end

    private

    def current_centers
      @num_of_clust.times.map { |clust| center clust }
    end

    def center k
      weights = points.map { |p| p.coef[k] ** @m }.sum
      points.map { |p| p.point * (p.coef[k] ** @m) }
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
