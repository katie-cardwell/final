# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
# upload with initial seed data for your Places
DB.create_table! :destinations do
  primary_key :id
  String :title
  String :description, text: true
  String :location
end
DB.create_table! :itineraries do
  primary_key :id
  foreign_key :destination_id
  foreign_key :user_id
  String :days
  String :name
  String :email
  String :schedule, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end


# Insert initial (seed) data
destinations_table = DB.from(:destinations)

destinations_table.insert(title: "Chicago", 
                    description: "Chicago is one of the largest cities in the US.  Located right on Lake Michigan, with the Lawrence River running through the middle, the metropolis has beautiful views.  Chicago is known for many things such as its deep-dish pizza, architecture, wind, and more.",
                    location: "Illinois, USA")

destinations_table.insert(title: "Montreal", 
                    description: "If you're looking for a European city, but can't go that far, Montreal is for you.  French-inspired Montreal is a beautiful city with countless activities to fill your weekend.",
                    location: "Quebec, Canada")
