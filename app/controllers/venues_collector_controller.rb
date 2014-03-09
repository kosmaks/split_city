class VenuesCollectorController < ApplicationController

  def update_venues
    config = SPLIT_CITY_GIS_CONFIG['fsq']
    client = Foursquare2::Client.new(:client_id     => config['client_id'], 
                                     :client_secret => config['client_secret'], 
                                     :api_version   => config['api_version'])

    categories = VenueCategory.where(:parent_id => nil)
    client.venue_categories()

  end

  def create_categories
    config = SPLIT_CITY_GIS_CONFIG['fsq']
    client = Foursquare2::Client.new(:client_id     => config['client_id'], 
                                     :client_secret => config['client_secret'], 
                                     :api_version   => config['api_version'])
    categories = client.venue_categories()

    VenueCategory.delete_all
    upsert_categories(categories)
  end

  def upsert_categories(data)
    def iterate(object, model)
      if not object.nil? and not object.categories.nil?
        child = save(object, model)
        object.categories.each do |x|
          iterate(x, child)
        end
      end 
    end
    
    def save(x, model)
      if model.nil?
        child = VenueCategory.new(:hash => x.id, :name => x.name)
        child.upsert
      else
        child = model.childs.new(:hash => x.id, :name => x.name)
        child.parent = model 
        child.upsert
      end
      child
    end

    data.each do |x| 
      iterate(x, nil)
    end
    return
  end

end
