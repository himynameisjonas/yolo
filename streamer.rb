require "rubygems"
require "bundler/setup"
require 'tweetstream'
require 'pusher'

TweetStream.configure do |config|
  config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token        = ENV['TWITTER_OAUTH_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
  config.auth_method        = :oauth
end

def stream
  TweetStream::Client.new.track("yolo") do |status, client|
    tweet = {
      id: status.id,
      text: status.text,
      screen_name: status.user.screen_name,
      profile_image_url: status.user.profile_image_url
    }
    Pusher['yolo'].trigger('tweet', tweet)
  end
end

configure do
  @@occupied = Time.now.to_i - 10000
  Pusher.app_id = ENV['PUSHER_APP_ID']
  Pusher.key = ENV['PUSHER_KEY']
  Pusher.secret = ENV['PUSHER_SECRET']
end

get '/alive' do
  @@occupied = Time.now.to_i
  "ok"
end

get '/' do
  content_type 'text/html', :charset => 'utf-8'
  erb :index
end

get '/:yolo' do
  content_type 'text/html', :charset => 'utf-8'
  @yolo = params[:yolo]
  @pusher = ENV['PUSHER_KEY']
  @@occupied = Time.now.to_i
  erb :stream
end

def occupied?
  @@occupied > Time.now.to_i - 1 * 30
end

EM.schedule do
  client = stream if @occupied
  EM::PeriodicTimer.new(5) do
    if occupied?
      client = stream unless client
    else
      client.stop if client
      client = nil
    end
  end
end