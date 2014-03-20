class ZoningController < ApplicationController
  def debug
    result = Venue.all

    respond_to do |format|
      format.json { render json: result }
      format.xml { render xml: result }
    end
  end
end
