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

    data = Venue.all
    .reject { |v| v.categories.count == 0 }
    .reject { |v| v.categories.first.name == 'Event' }
    .map do |venue|
      category = venue.categories.first
      json = venue.as_json
      json[:category_id] = category.id.to_s
      json[:category_name] = category.name
      json
    end

    respond_to do |format|
      format.json { render json: data }
    end
  end
end
