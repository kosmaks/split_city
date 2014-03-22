class ZoningController < ApplicationController
  def debug

    fcm = Mongoid::FCM.new element: Venue, result: Cluster

    result = {
      venues: fcm.run.map(&:value),
      centers: fcm.compute_centers.map { |x| x['value'] }
    }
    
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
