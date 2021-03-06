class ZoningController < ApplicationController
  include GeoHelper

  def debug


    #fcm = Mongoid::FCM.new element: Venue, result: Cluster

    #result = {
    #  venues: fcm.run.map(&:value),
    #  centers: fcm.compute_centers.map { |x| x['value'] }
    #}
    
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
    .map do |venue|
      json = venue.as_json
      json[:categories] = venue.categories.map do |cat|
        { name: cat.name, id: cat.id.to_s }
      end
      json
    end

    respond_to do |format|
      format.json { 
        render(json: {
          venues: data,
          cache: Cache.all.entries
        })
      }
    end
  end

  def random
    data = []
    cats = VenueCategory.all.to_a

    count = params[:count].to_i
    count = (count < 0) ? 0 : \
            (count > 20000) ? 20000 : count

    count.times do
      cat = cats[rand(cats.count)]
      data << {
        lat: 55.15 + (0.1 * rand - 0.05),
        lng: 61.37 + (0.1 * rand - 0.05),
        name: 'Random',
        categories: [ { name: cat.name, id: cat.id.to_s } ]
      }
    end

    respond_to do |format|
      format.json { 
        render(json: {
          venues: data 
        })
      }
    end
  end

  def save
    Cache.create data: params[:clusters], n: params[:n]
    render json: {}
  end
end
