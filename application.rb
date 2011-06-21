require "sinatra"
require 'nokogiri'
require 'net/http' 
require 'net/https'

get '/' do
  begin
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
      else
        return "failed" + res.to_s
    end

    erb :index
  rescue Exception => e
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
<% @image_urls.each do |url| %>
  <p><img src="<%= url %>"></p>
<% end %>

@@ error
<p>Oops! Something went wrong...</p>