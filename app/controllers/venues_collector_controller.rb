class VenuesCollectorController < ApplicationController

  def update_venues_from_fsq
    config = SPLIT_CITY_GIS_CONFIG['fsq']
    client = Foursquare2::Client.new(:client_id     => config['client_id'], 
                                     :client_secret => config['client_secret'], 
                                     :api_version   => config['api_version'])

    categories     = VenueCategory.all.map{ |x| x.fsq_venue_category }
    category_tree  = client.venue_categories

    categories.each do |x|
      venues = client.search_venues(:near => "Chelyabinsk", \
                                    :limit => 50, \
                                    :categoryId => x.category_id).venues
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
          
          category = categories.find { |cat| cat.category_id == parent_category.id}.venue_category

          v.categories << category
          v.save
        end
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
