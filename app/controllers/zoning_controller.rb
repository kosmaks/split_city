class ZoningController < ApplicationController
  def debug
    venues = Venue.all.limit(10).to_a

    result = Clust::FCM.new([1, 2, 7, 8, 9], 2).run

    respond_to do |format|
      format.json { render json: result }
      format.xml  { render xml:  result }
    end
  end
end
