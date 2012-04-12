# coding: utf-8

require 'sinatra'
# require 'sinatra/flash'
require 'haml'
require 'yaml'
require 'base64'
require 'pp'

configure do
  set :haml, {:format => :html5 }
  set :method_override, true
  set :logging, true
  set :public_folder, File.dirname(__FILE__) + '/public'
#  enable :sessions
end


## set appsettings (to config later)
@@config = YAML::load_file("./config/config.yml")

@@files = @@config["files"]
@@tasks = @@config["tasks"]


get "/" do
  haml :index
end

get "/tasks" do  
  haml :tasks
end

get "/files/:id" do  
  @id = params[:id]
  @filepath=@@files[params[:id]]["path"]
  haml :fileedit
end

put "/files/:id" do
  @id = params[:captures][0]
  @text = params[:text]
  File.open(@@files[@id]["path"],"w") do |f|
    f.puts @text
  end
  redirect '/'
end

post "/perform/:task" do
  @cmdline = @@tasks[params[:task]]["task"]
  @result = `#{@cmdline}`
  haml :results
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
%hr
%h2 Files
%p edit your files.
- @@files.each do |id, file|
  %article
    %h3= file["path"]
    %p Type => #{file["type"]}
    %a{:href => "files/#{id}"} Edit this file.
    %pre
      %code= File.read(file["path"])
%hr
%h2 Tasks
-# %code= @@tasks
%table
  %tr
    %th Perform
    %th TaskName
    %th Description
  - @@tasks.each do |name, attr|
    %tr
      %td
        %form{:method => 'POST', :action => "/perform/#{name}"}
          %input.btn{:type => 'submit', :value => "Perform"} 
      %td= attr["label"]
      %td= attr["desc"]

@@tasks
%h1 Tasks.
%p Perform your tasks.
%code= @@tasks

@@results
%h1 Done
%a{:href => "/"} Return
%p
  %pre
    %code=  @cmdline = @@tasks["#{params[:task]}"]["task"]
%h2 Result here
%p
  %pre
    %code= @result

@@fileedit
%h1 File.
%p= @filepath
%form{:method => 'POST', :action => "/files/#{@id}", :enctype => 'text/plane'}
  %input{:type => 'hidden', :name => '_method', :value  => 'put'}
  %textarea{:name => "text", :rows => 30, :cols => 75}= File.read(@filepath)
  %input{:type => 'hidden', :name => 'path', :value  => @filepath}
  %input.btn-primary.btn-large{:type => 'submit', :value => 'update'}
%a{:href => "/"} Return
    