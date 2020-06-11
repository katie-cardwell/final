# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "geocoder"                                                                    #
require "bcrypt"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

# App program that allows consumption of the place data (i.e. at a minimum, a list of places and a detail page for each place), and an interface to allow associated data to be user-generated

# events_table = DB.from(:events)
# rsvps_table = DB.from(:rsvps)

destinations_table = DB.from(:destinations)
itineraries_table = DB.from(:itineraries)
# reviews_table = DB.from(reviews)
users_table = DB.from(:users)

before do 
    # SELECT * FROM users WHERE id = session[:user_id]
    @current_user = users_table.where(:id => session[:user_id]).to_a[0]
    puts @current_user.inspect
end

# Home page (all destinations)
get "/" do 
    # before stuff runs
    @destinations = destinations_table.all
    @itineraries = itineraries_table.all
    puts @destinations.inspect
    view "destinations"
end

# Show a single destination
get "/destinations/:id" do 
    @users_table = users_table
    @destination = destinations_table.where(:id => params[:id]).to_a[0]
    @itinerary = iteneraries_table.where(:destination_id => params["id"]).to_a
    #@average = reviews_table.where(:destination_id => params["id"], :itinerary_id => params["id"]).average
    view "destination"
end

# form to create a new itinerary
get "/destinations/:id/itineraries/new" do 
    @destination = destinations_table.where(:id => params["id"]).to_a[0]
    view "new_itinerary"
end

#Receiving end of new Itinerary form
post "/destinations/:id/itineraries/create" do 
    itineraries_table.insert(:destination_id => params["id"],
                             :price_range => params["cost"],
                             :user_id => @current_user[:id],
                             :days => params["days"],
                             :type => params["type"]
                             :schedule => params["schedule"])
    @destination = destinations_table.where(:id => params["id"]).to_a[0]
    view "create_itinerary"
end

#Form to create a new user
get "/users/new" do 
    view "new_user"
end

# Receiving end of new user form
post "/users/create" do 
    users_table.insert(:name => params["name"],
                       :email => params["email"],
                       :password => params["password"])
    view "create_user"
end

# form to login
get "/logins/new" do 
    view "new_login"
end

#Receiving end of login form
post "/logins/create" do 
    puts params
    email_entered = params["email"]
    password_entered = params["password"]
    user = users_table.where(:email => email_entered).to_a[0]
    if user
        puts user.inspect
        if user[:password] == password_entered
            session[:user_id] = user[:id]
            view "create_login"
        else 
            view "create_login_failed"
        end
    else
        view "create_login_failed"
    end
end

get "/logout" do 
    view "logout"
end
