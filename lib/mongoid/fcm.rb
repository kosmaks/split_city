module Mongoid
  module FCM

    module StaticMethods

      def run_fcm params={}
        m        = params[:m]            || 2.0
        e        = params[:e]            || 1e-4
        values   = params[:value_fields] || [:value]
        coef     = params[:coef_field]   || :coef
        clusters = params[:clusters]     || 2

        coef   = "'#{coef.to_s.gsub(/'/, "\\'")}'"
        values = values.map { |x| "'#{x.to_s.gsub(/'/, "\\'")}'" }
        mpower = 2.0 / (m - 1.0)

        zero = "{#{values.map { |x| "#{x}: 0.0" }.join(',')}}"

        def dist values, left, right
          if values.count == 1
            "Math.abs(#{left}[#{values[0]}] - #{right}[#{values[0]}])"
          else
            "Math.sqrt(" + values.map do |val|
              "Math.pow(#{left}[#{val}] - #{right}[#{val}], 2)"
            end.join("+") + ")"
          end
        end

        # fill with random data
        execjs %Q{ 
          function() {
            function randomWeights() {
              var sum = 1000.0;
              var res = [];
              for (var i = 0; i < (#{clusters - 1}); ++i) {
                var perc = Math.floor(Math.random() * sum);
                perc = (perc > sum) ? sum : perc;
                res.push(perc);
                sum -= perc;
              }
              res.push(sum);
              return res.map(function(x) { return x / 1000.0 });
            }

            #{dbcoll}.find().forEach(function(rec) {
              rec[#{coef}] = randomWeights();
              #{dbcoll}.save(rec);
            })
          } 
        }

        execjs %Q{
          function() {
            function getCenter(cluster) {
              var denom = 0;
              var numer = #{zero};

              #{dbcoll}.find().forEach(function(rec) {
                var k = Math.pow(rec.coef[cluster], #{m});
                denom += k;

                #{values.map do |val|
                  "numer[#{val}] += rec[#{val}] * k;"
                end.join(';')}
              });

              if (denom != 0) {
                #{values.map do |val|
                  "numer[#{val}] /= denom;"
                end.join(';')}
                return numer;
              }
            }

            function getCenters() {
              var centers = [];
              for (var i = 0; i < #{clusters}; ++i) {
                centers[i] = getCenter(i);
              }
              return centers;
            }

            function normalize() {
              var centers = getCenters();
              var maxdiff = 0.0;

              #{dbcoll}.find().forEach(function(rec) {
                for (var i = 0; i < #{clusters}; ++i) {

                  var sum = 0;
                  for (var j = 0; j < #{clusters}; ++j) {
                    sum += Math.pow(#{dist values, "rec", "centers[i]"} / 
                                    #{dist values, "rec", "centers[j]"}, 
                                    #{mpower});
                  }

                  var newval = (sum != 0)
                             ? 1 / sum
                             : rec[#{coef}][i];
                  var diff = Math.abs(newval - rec[#{coef}][i]);
                  if (diff > maxdiff) maxdiff = diff;

                  rec[#{coef}][i] = newval;
                }

                #{dbcoll}.save(rec);
              });

              return maxdiff;
            }

            while (normalize() > #{e.to_json}) {}
          }  
        }
      end

      private

      def execjs src
        collection.database.command(:$eval => src, :nolock => true)['retval']
      end

      def dbcoll; "db.#{collection_name}"; end

    end

    def self.included o
      o.extend StaticMethods
    end
  end
end
