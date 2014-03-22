module Mongoid
  class FCM
    def initialize params={}
      @m       = params[:m]               || 2.0
      @e       = params[:e]               || 1e-4
      @clust   = params[:num_of_clusters] || 8
      @elem    = params[:element]
      @result  = params[:result]

      scope params[:scope]

      raise ArgumentError.new 'Element model is not set' if @elem.nil?
      raise ArgumentError.new 'Element model must implement Mongoid::FCM::Element' \
        unless @elem.included_modules.include? Element

      raise ArgumentError.new 'Center model is not set' if @result.nil?
      raise ArgumentError.new 'Center model must implement Mongoid::FCM::Result' \
        unless @result.included_modules.include? Result
    end

    def scope name
      @scope = name unless name.nil?
    end

    def run
      fill_random
      while true do
        weights
        max_diff = @result.max('value.max_diff')
        break if max_diff <= @e
      end
      @result.all
    end

    def fill_random
      map = %Q{
        function() {
          var result = this;
          result.weights = [];
          result.max_diff = 0.1;

          var max = 1.0;
          for (var i = 0; i < #{@clust - 1}; ++i) {
            var val = Math.random() * max;
            if (val > max) val = max;
            result.weights.push(val);
            max -= val;
          }
          result.weights.push(max);
          emit(this._id, result);
        }
      }
      elements.map_reduce(map, '').out(replace: @result.collection_name).time
    end
    
    def compute_centers
      map = %Q{
        function() {
          var value = this.value;

          for (var i in value.weights) {
            var coef = value.weights[i];
            var denum = Math.pow(coef, #{@m});
            var values = {
              #{
                values_ do |val|
                  "#{val}: value[#{val}] * denum"
                end.join(',')
              }
            };
            emit(Number(i), { values: values, denum: denum });
          }
        }
      }

      reduce = %Q{
        function(key, values) {
          var result = { 
            values: { #{values_ { |v| "#{v}:0" }.join(',')} }, 
            denum: 0 
          };
          values.forEach(function(value) {
            #{
              values_ do |val|
                "result.values[#{val}] += value.values[#{val}];"
              end.join
            }
            result.denum += value.denum;
          });
          return result;
        }
      }

      final = %Q{
        function(key, value) {
          return {
            #{
              values_ do |val|
                "#{val}: value.values[#{val}] / value.denum"
              end.join(',')
            }
          };
        }
      }

      @result.all.map_reduce(map, reduce).out(inline: true).finalize(final).to_a
    end

    def weights
      centers = compute_centers

      map = %Q{
        function() {
          var weights = this.value.weights;
          var centers = #{centers.to_json};
          var cache = {};

          var max = 0;
          for (var i in centers) {
            var sum = 0.0;
            for (var j in centers) {
              var disti = cache[i];
              var distj = cache[j];
              if (disti == undefined) cache[i] = disti = #{dist_ 'centers[i].value', 'this.value'};
              if (distj == undefined) cache[j] = distj = #{dist_ 'centers[j].value', 'this.value'};

              sum += Math.pow(disti / distj, #{mpow});
            }

            var newvalue = 1 / sum;
            var oldvalue = this.value.weights[i];
            var diff = Math.abs(newvalue - oldvalue);
            if (diff > max) max = diff;
            this.value.weights[i] = newvalue;
          }

          this.value.max_diff = max;
          emit(this._id, this.value);
        }
      }

      @result.all.map_reduce(map, '').out(replace: @result.collection_name).time
    end
    
    #private

    def elements
      @scope.nil? ? @elem.all : @elem.send(@scope)
    end

    def mpow
      2.0 / (@m - 1)
    end

    def coef
      @coef ||= @elem.fcm_coef
    end

    def coef_
      @formated_coef ||= escape(coef)
    end

    def dist_ left, right 
      "Math.sqrt(" +
        values_ do |val|
          "Math.pow(#{left}[#{val}] - #{right}[#{val}], 2)"
        end.join(' + ') +
        ")"
    end

    def values_ &block
      @formated_values ||= @elem.fcm_keys.map(&method(:escape))
      if block.nil? 
        @formated_values
      else
        @formated_values.map(&block)
      end
    end

    def escape key
      "'#{key.to_s.gsub(/\'/, "\\'")}'"
    end
  end
end
