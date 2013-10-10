require 'yaml'
require 'twitter'

config = nil
if File.exist?("config.yml")
  config = YAML.load(open("config.yml"))
end
Twitter.configure do |c|
  c.consumer_key =  ENV["CONSUMER_KEY"] || config["CONSUMER_KEY"]
  c.consumer_secret = ENV["CONSUMER_SECRET"] || config["CONSUMER_SECRET"]
  c.oauth_token =  ENV["OAUTH_TOKEN"] || config["OAUTH_TOKEN"]
  c.oauth_token_secret =  ENV["OAUTH_TOKEN_SECRET"] || config["OAUTH_TOKEN_SECRET"]
end


client = Twitter::Client.new

puts "client starting"

Twitter.search("psychogeography", :count => 3, :result_type => "recent").results.map do |status|
  puts "#{status.from_user}: #{status.text}"
end

#client.update("But the irreversible time of the bourgeois economy eradicates these vestiges on every corner of the globe.")
