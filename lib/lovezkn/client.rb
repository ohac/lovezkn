require 'rubytter'

module LoveZkn
  CONFIG = Pit.get('twitter_api')
  APIKEY = CONFIG['apikey']
  SECRET = CONFIG['secret']
  PASSWORD = CONFIG['password']

  class Client
    def initialize
      if APIKEY.nil? && PASSWORD.nil?
        puts 'Save below parameters in into ~/.pit/default.yaml'
        puts
        puts '# OAuth version'
        puts 'twitter_api: '
        puts "  apikey: (Your API Key)"
        puts "  secret: (Your API Secret)"
        puts
        puts '# Basic Authentication version'
        puts 'twitter_api: '
        puts "  screen_name: (Your Screen Name)"
        puts "  password: (Your Password)"
        raise
      end
      @oauth = Rubytter::OAuth.new(APIKEY, SECRET)
    end

    def login
      oauth_token = CONFIG['oauth_token']
      screen_name = CONFIG['screen_name']
      options = {
        :host => CONFIG['host'],
        :path_prefix => CONFIG['path_prefix'],
      }
      access_token = nil
      if PASSWORD
        @client = Rubytter.new(screen_name, PASSWORD, options)
      elsif oauth_token.nil?
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
      @screen_name = screen_name
      @client = OAuthRubytter.new(access_token, options) if access_token
      @client
    end
    attr_reader :user_id, :screen_name
  end
end
