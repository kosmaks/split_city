class VenuesCollectorController < ApplicationController

  def updateDataFromFsq
    config = SPLIT_CITY_GIS_CONFIG['fsq']
    client = Foursquare2::Client.new(:client_id     => config['client_id'], 
                                     :client_secret => config['client_secret'], 
                                     :api_version   => config['api_version'])
    puts client.search_venues(:near => 'Chelyabinsk')

  end
end
