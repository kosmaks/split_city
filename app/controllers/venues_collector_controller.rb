class VenuesCollectorController < ApplicationController
  include GeoHelper

  def update_venues_from_fsq
    config      = SPLIT_CITY_GIS_CONFIG['fsq']
    query_limit = config['query_limit'].to_i
    client = Foursquare2::Client.new(:client_id     => config['client_id'], 
                                     :client_secret => config['client_secret'], 
                                     :api_version   => config['api_version'])

    categories     = VenueCategory.all.map{ |x| x.fsq_venue_category }
    category_tree  = client.venue_categories

    i = 0

    qnts = getQuadrants
    qnts.each do |x|
      break if (i += 1) > query_limit
      categories.each do |y|
        sw, ne = x.quadrant.map{ |x| x * "," }
        venues = client.search_venues(:sw => sw,
                                      :limit => 50, 
                                      :intent => 'browse',
                                      :category_id => y.category_id,
                                      :ne => ne).venues
        venues.each do |venue|
          next if venue.location.nil?
          next if venue.categories.nil? or venue.categories.empty?

          Venue.where(:venue_id => venue.id)
               .first_or_create
               .update(:name => venue.name,
                       :lat  => venue.location.lat,
                       :lng  => venue.location.lng)
          v = Venue.where(:venue_id => venue.id).first
          venue.categories.each do |y|
            parent_category = find_parent_category(category_tree, y)
            next if parent_category.nil?
          
            category = categories.find { |cat| cat.category_id == parent_category.id}
            next if category.nil?

            v.categories << category.venue_category
            v.save
          end
        end
      end
      x.latest_update = Time.now
      x.save
    end
  end

  def getQuadrants
    config      = SPLIT_CITY_GIS_CONFIG['fsq']
    update_freq = config['update_frequency'].to_i

    quadrants = CollectorInfo.all
    quadrants.reject{|x| (Time.now - x.latest_update) < update_freq}
  end

  def saveQuadrants
    cities = City.all 
    cities.each do |city|
      next if !city.nil? or city.count > 0
      qnts = quadrants city.borders, 100
      qnts.each do |qnt|
        collector_info = CollectorInfo.create(:quadrant => qnt)

        c = City.where(_id: city._id).first
        c.collector_info.push(collector_info)
        c.save

        collector_info.city = c
        collector_info.save
      end
    end
  end

  def find_parent_category(tree, category)
    tree.each do |subtree|
      return subtree if find_in_parent_category(subtree, category)
    end
    nil
  end

  def find_in_parent_category(subtree, category)
    return false if subtree.categories.nil?
    subtree.categories.each do |branch|
      return true if category.id == branch.id 
      next if branch.categories.nil?

      find_in_parent_category(branch, category)
    end
    false
  end
end
