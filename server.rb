# coding: utf-8

require 'sinatra'
# require 'sinatra/flash'
require 'haml'
require 'yaml'
require 'base64'
require 'pp'

configure do
  set :haml, {:format => :html5 }
  set :public_folder, File.dirname(__FILE__) + '/public'
  enable :sessions
end


## set appsettings (to config later)
@@config = YAML::load_file("./config/config.yml")
@@tasks = @@config["tasks"]


get "/" do
  haml :index
end

get "/tasks" do  
  haml :tasks
end


__END__

@@layout
%html
  %head
    %meta{ :charset => "utf-8"}
    %link{ :href => "css/bootstrap.css", :rel => "stylesheet"}
    %link{ :href => "css/jquery-ui.css", :rel => "stylesheet"}
    %script{ :type => "text/javascript", :src => "js/jquery-1.7.1.min.js" }
    %script{ :type => "text/javascript", :src => "js/jquery-ui-1.8.17.custom.min.js" }
    %script{ :type => "text/javascript", :src => "js/smd.js" }
    %title Files and Tasks - simple server management.
  %body
    %div.container{:style => "padding: 15px;"}
      = yield


@@index
%h1 Files and Tasks.

@@tasks
%h1 Tasks.
- @@tasks.each do |task|
  %h2= task["name"]
  %p=  task["desc"]
  %code=  task["task"]