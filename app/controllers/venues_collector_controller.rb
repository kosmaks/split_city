class VenuesCollectorController < ApplicationController

  def update_venues_from_fsq
    config = SPLIT_CITY_GIS_CONFIG['fsq']
    client = Foursquare2::Client.new(:client_id     => config['client_id'], 
                                     :client_secret => config['client_secret'], 
                                     :api_version   => config['api_version'])

    categories = VenueCategory.all.map{ |x| x.fsq_venue_category }
    categories.each do |x|
      venues = client.search_venues(:near => "Chelyabinsk", :limit => 50, :categoryId => x.category_id).venues
      venues.each do |venue|
        next if venue.location.nil?
        next if venue.categories.nil? or venue.categories.empty?

        Venue.where(:venue_id => venue.id)
             .first_or_create
             .update(:name => venue.name,
                     :lat  => venue.location.lat,
                     :lng  => venue.location.lng)
        v = Venue.where(:venue_id => venue.id).first

        venue.categories.each do |x|
          v.categories << categories.find {|cat| cat.category_id == x.id}
        end
      end
    end
  end

end
