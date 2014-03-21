class ZoningController < ApplicationController
  def debug

    result = []
    #result = {
      #venues: Venue.all,
      #centers: centers
    #}
    
    #result = Venue.all.map { |x| [x.lat, x.lng] }
    #result = Clust::FCM.new(result, 8).run

    respond_to do |format|
      format.json { render json: result }
      format.xml  { render xml:  result }
    end
  end

  def index
    respond_to do |format|
      format.json { render json: Venue.all }
    end
  end
end
