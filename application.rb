require "sinatra"
require 'nokogiri'
require 'net/http' 
require 'net/https'
require 'dalli'

# cache 6 hours
cache = Dalli::Client.new(nil, {:expires_in => 60*60*6})
set :cache, cache


get '/' do

  begin
    @image_urls = settings.cache.get('urls')
    @time = settings.cache.get('time')
    
    if @image_urls.nil?
      url = "https://github.com/MrMEEE/bumblebee/commit/a047be85247755cdbe0acce6f1dafc8beb84f2ac"
      url = URI.parse( url )
      http = Net::HTTP.new( url.host, url.port )
      http.use_ssl = true if url.port == 443
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if url.port == 443
      # path = url.path + "?" + url.query
      path = url.path
      res, data = http.get( path )

      @image_urls = Array.new

      case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          # parse link
          doc = Nokogiri::HTML(data)
          doc.css('div.comment').each do |comment|
            comment.search('div.body img').each do |img|
              @image_urls << img["src"]
            end
          end
          settings.cache.set('urls', @image_urls)
          settings.cache.set('time', Time.now)
        else
          return "failed" + res.to_s
      end
    end

    @time = Time.now if @time.nil?
    erb :index
  rescue Exception => e
    @message = e.message
    erb :error
  end
  
  
end

__END__

@@ layout
<html>
  <head>
    <title>/USR GOT REMOVED!</title>
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js" ></script>
  </head>
  <body>

    <%= yield %>

  </body>
</html>

@@ index
Image grabbed at <%=@time%>
<% @image_urls.each do |url| %>
  <p><img src="<%= url %>"></p>
<% end %>

@@ error
<p>Oops! Something went wrong...</p>
<p>Detail:: <%= @message %></p>