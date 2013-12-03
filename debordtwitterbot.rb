require 'yaml'
require 'twitter'
require 'marky_markov'

def truncate(text, length = 30)
  l = text[0..length].rindex(" ")
  chars = text.chars
  if chars.length > length
    new_text = chars[0...l].join + "..."
  else
    new_text = text
  end
  
  return new_text
end


#
# markov chain the text
#
@markov = MarkyMarkov::TemporaryDictionary.new
@markov.parse_file "debord.txt"

def create_tweet
  raw_text = @markov.generate_23_words
  tweet_length = (110..135).to_a.sample
  tweet = truncate(raw_text, tweet_length)

  tweet
end

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

old_tweet_id = client.user_timeline(client.user, {:count => 1, :exclude_replies => true})[0].id

#
# create and send the new tweet
#
tweet = create_tweet
puts "sending text: " + tweet
new_tweet = client.update(tweet)

#
# replies to last 3 questions
#
mentions = client.mentions({ :since_id => old_tweet_id, :count => 3})

mentions.each do | m |

if m.in_reply_to_user_id == client.user.id
  reply  = "@#{m.user.screen_name} "+create_tweet()
  puts "sending reply "+ reply
  
  client.update(reply, {:in_reply_to_status => m})
end

end

#
# Now follow some people
#
if false
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
    #client.follow(new_user)
  end unless to_follow.empty?
  
end
