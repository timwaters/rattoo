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

markov = MarkyMarkov::TemporaryDictionary.new
markov.parse_file "/home/tim/projects/rattoo/debord.txt"

raw_text = markov.generate_25_words

tweet =  raw_text[0..132]

client = Twitter::Client.new

puts "sending text: " + tweet
client.update(tweet)

