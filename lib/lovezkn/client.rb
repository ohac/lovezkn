require 'rubytter'

module LoveZkn
  CONFIG = Pit.get('twitter_api')
  APIKEY = CONFIG['apikey']
  SECRET = CONFIG['secret']

  class Client
    def initialize
      if APIKEY.nil?
        puts 'Save below parameters in into ~/.pit/default.yaml'
        puts
        puts 'twitter_api: '
        puts "  apikey: (Your API Key)"
        puts "  secret: (Your API Secret)"
        raise
      end
      @oauth = Rubytter::OAuth.new(APIKEY, SECRET)
    end

    def login
      oauth_token = CONFIG['oauth_token']
      access_token = nil
      if oauth_token.nil?
        request_token = @oauth.get_request_token
        puts "Access here: #{request_token.authorize_url}"
        puts 'and...'
        print "Enter PIN: "
        pin = gets.strip
        access_token = request_token.get_access_token(
          :oauth_token => request_token.token,
          :oauth_verifier => pin
        )
        puts 'Add below parameters in into ~/.pit/default.yaml'
        puts
        puts 'twitter_api: '
        puts "  oauth_token: #{access_token.token}"
        puts "  oauth_token_secret: #{access_token.secret}"
        puts "  user_id: #{access_token.params[:user_id]}"
        puts "  screen_name: #{access_token.params[:screen_name]}"
      else
        oauth_token_secret = CONFIG['oauth_token_secret']
        user_id = CONFIG['user_id']
        screen_name = CONFIG['screen_name']
        consumer = @oauth.create_consumer
        access_token = OAuth::AccessToken.new(consumer, oauth_token,
            oauth_token_secret)
        access_token.params[:user_id] = user_id
        access_token.params["user_id"] = user_id
        access_token.params[:screen_name] = screen_name
        access_token.params["screen_name"] = screen_name
        access_token.params[:oauth_token] = oauth_token
        access_token.params["oauth_token"] = oauth_token
        access_token.params[:oauth_token_secret] = oauth_token_secret
        access_token.params["oauth_token_secret"] = oauth_token_secret
      end
      @user_id = user_id
      @client = OAuthRubytter.new(access_token)
    end
    attr_reader :user_id
  end
end
