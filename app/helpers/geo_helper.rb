module GeoHelper
  include Math

  def distance loc1, loc2
    lat1, lon1 = loc1
    lat2, lon2 = loc2
    dLat = to_rad lat2 - lat1
    dLon = to_rad lon2 - lon1
    a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(to_rad lat1) * Math.cos(to_rad lat2) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    d = 6371 * c; 
  end

  def to_rad number
      number * Math::PI / 180
  end

  def quadrants borders, count
    lat1, lon1  = borders[0]
    lat2, lon2 = borders[1]

    cnt = sqrt(count).to_i
  
    dLat = (lat2 - lat1) / cnt
    dLon = (lon2 - lon1) / cnt
    
    result = []

    for i in 0..cnt - 1 do
      for j in 0..cnt - 1 do
          result.push([[lat1 + i * dLat, lon1 + j * dLon],
                       [lat1 + (i + 1) * dLat, lon1 + (j + 1) * dLon]])
      end
    end 

    result
  end

end
