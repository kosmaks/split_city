module Mongoid
  class FCM
    def initialize params={}
      @m     = params[:m]               || 2.0
      @e     = params[:e]               || 1e-2
      @clust = params[:num_of_clusters] || 3
    end
    
    def centers
      values = values.map { |x| "'#{x.to_s.gsub(/'/, "\\'")}'" }

      centersMap = %Q{
        function() {
          for (var i in this.coef) {
            var coef = this.coef[i];
            var denum = Math.pow(coef, #{m});
            var values = {
              #{values.map do |value|
                "#{value}: this[#{value}]"
              end.join(',')}
            };
            emit(i, { values: values, denum: denum });
          }
        }
      }

      centersReduce = %Q{
        function(key, values) {
          var result = { 
            values: { #{values.map { |v| "#{v}:0" }.join(',')} }, 
            denum: 0 
          };
          values.forEach(function(value) {
            #{values.map do |value|
              "result.values[#{value}] += value.values[#{value}];"
            end.join}
            result.denum += value.denum;
          });
          return result;
        }
      }

      all.map_reduce(centersMap, centersReduce).out(replace: :centers)
    end
  end
end
