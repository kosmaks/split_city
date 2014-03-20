class ZoningController < ApplicationController
  def debug
    venues = Venue.all.limit(10).to_a

    result = Clust::FCM::run

    respond_to do |format|
      format.json { render json: result }
      format.xml  { render xml:  result }
    end
  end
end
