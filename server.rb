# coding: utf-8

require 'sinatra'
# require 'sinatra/flash'
require 'haml'
require 'yaml'
require 'base64'
require 'pp'

configure do
  set :haml, {:format => :html5}
#  set :haml, {:format => :html5, :escape_html => true }
#  Haml::Template.options[:escape_html] = true
  set :method_override, true
  set :logging, true
  set :public_folder, File.dirname(__FILE__) + '/public'
#  enable :sessions
end


## set appsettings (to config later)
@@flaks = YAML::load_file("./config/flaks.yml")


get "/" do
  haml :index
end

get "/:name" do  
  @name = params[:name]
  @flak = @@flaks[@name]
  haml :flaks
end

get "/:name/files/:id" do  
  @id = params[:id]
  @name = params[:name]
  @filepath=@@flaks[@name]["files"][@id]["path"]
  haml :fileedit
end

put "/:name/files/:id" do
  @id = params[:captures][0]
  @text = params[:text]
  @name = params[:name]
  @id = params[:id]
  @flak = @@flaks[@name]
  File.open(@@flaks[@name]["files"][@id]["path"],"w") do |f|
    f.puts @text.gsub(/\r\n/,"\n")
  end
  redirect "/#{@name}"
end

post "/:name/tasks/:id" do
  @name = params[:name]
  @id = params[:id]
  @cmdline = @@flaks[@name]["tasks"][@id]["task"]
  @result = `#{@cmdline}`
  haml :results
end


__END__

@@layout
%html
  %head
    %meta{ :charset => "utf-8"}
    %link{ :href => "/css/bootstrap.css", :rel => "stylesheet"}
    %link{ :href => "/css/jquery-ui.css", :rel => "stylesheet"}
    %script{ :type => "text/javascript", :src => "/js/jquery-1.7.1.min.js" }
    %script{ :type => "text/javascript", :src => "/js/jquery-ui-1.8.17.custom.min.js" }
    %script{ :type => "text/javascript", :src => "/js/smd.js" }
    %title Files and Tasks - simple server management.
  %body
    %div.container{:style => "padding: 15px;"}
      = yield


@@flaks
%h1= @name
%h3= @flak["desc"]
%hr
%p
  %a{:href => "/"}TOP
%h2 Files
%p edit your files.
- @flak["files"].each do |id, file|
  %article
    %h3= file["path"]
    %p Type => #{file["type"]}
    %a{:href => "/#{@name}/files/#{id}"} Edit this file.
    %pre
      %code&= File.read(file["path"])
%h2 Tasks
-# %code= @@tasks
%table.table
  %tr
    %th Perform
    %th TaskName
    %th Description
  - @flak["tasks"].each do |name, attr|
    %tr
      %td
        %form{:method => 'POST', :action => "/#{@name}/tasks/#{name}"}
          %input.btn{:type => 'submit', :value => "Perform"} 
      %td= attr["label"]
      %td&= attr["desc"]

@@results
%h1 Done
%a{:href => "/#{@name}"} Return
%p
  %pre
    %code=  @cmdline
%h2 Result here
%p
  %pre
    %code= @result

@@fileedit
%h1 File.
%p= @filepath
%form{:method => 'POST', :action => "/#{@name}/files/#{@id}", :enctype => 'text/plane'}
  %input{:type => 'hidden', :name => '_method', :value  => 'put'}
  %textarea{:name => "text", :style => 'height: 40em; width: 60em;'}= File.read(@filepath)
  %input{:type => 'hidden', :name => 'path', :value  => @filepath}
  %input.btn-primary.btn-large{:type => 'submit', :value => 'update'}
%a{:href => "/#{@name}"} Return
