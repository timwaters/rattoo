require 'yaml'
require 'twitter'
require 'marky_markov'


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


#
# markov chain the text
#
markov = MarkyMarkov::TemporaryDictionary.new
markov.parse_file "debord.txt"
raw_text = markov.generate_25_words
tweet =  raw_text[0..132]


client = Twitter::Client.new

#
# send the tweet
#

puts "sending text: " + tweet
client.update(tweet)

#
# Now follow some people
#

to_follow = []
client.search("psychogeography", :count => 3, :result_type => "recent").results.map do |status|
 to_follow << status.from_user
end
client.search("guy debord", :count => 3, :result_type => "recent").results.map do |status|
 to_follow << status.from_user
end

to_follow.uniq!

to_follow.each do | new_user |
  puts "following: " + new_user
  client.follow(new_user)
end unless to_follow.empty?

