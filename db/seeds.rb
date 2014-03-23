# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


VenueCategory.create(name: "Arts & Entertainment")
             .create_fsq_venue_category(name: "Arts & Entertainment", \
                                        category_id: "4d4b7104d754a06370d81259")
VenueCategory.create(name: "College & University")
             .create_fsq_venue_category(name: "College & University", \
                                        category_id: "4d4b7105d754a06372d81259")
VenueCategory.create(name: "Event")
             .create_fsq_venue_category(name: "Event", \
                                        category_id: "4d4b7105d754a06373d81259")
VenueCategory.create(name: "Food")
             .create_fsq_venue_category(name: "Food", \
                                        category_id: "4d4b7105d754a06374d81259")
VenueCategory.create(name: "Nightlife spot")  
             .create_fsq_venue_category(name: "Nightlife spot", \
                                        category_id: "4d4b7105d754a06376d81259")
VenueCategory.create(name: "Outdoors & Recreation")
             .create_fsq_venue_category(name: "Outdoors & Recreation", \
                                        category_id: "4d4b7105d754a06377d81259")
VenueCategory.create(name: "Professional & Other")
             .create_fsq_venue_category(name: "Professional & Other Places", \
                                        category_id: "4d4b7105d754a06375d81259")
VenueCategory.create(name: "Residence")
             .create_fsq_venue_category(name: "Residence", \
                                        category_id: "4e67e38e036454776db1fb3a")

VenueCategory.create(name: "Shop & Service")
             .create_fsq_venue_category(name: "Shop & Service", \
                                        category_id: "4d4b7105d754a06378d81259")

VenueCategory.create(name: "Travel & Transport")
             .create_fsq_venue_category(name: "Travel & Transport", \
                                        category_id: "4d4b7105d754a06378d81259")

City.create(name: "Chelyabinks", 
            borders: [[55.045429, 61.247772], [55.375323, 61.566752]])

