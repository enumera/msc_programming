require 'google/apis'
require 'google/apis/youtube_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'pry'
require 'fileutils'
require 'json'

# REPLACE WITH VALID REDIRECT_URI FOR YOUR CLIENT
REDIRECT_URI = 'http://localhost'
APPLICATION_NAME = 'YouTube Data API Ruby Tests'

# REPLACE WITH NAME/LOCATION OF YOUR client_secrets.json FILE
CLIENT_SECRETS_PATH = 'client_secret.json'

# REPLACE FINAL ARGUMENT WITH FILE WHERE CREDENTIALS WILL BE STORED
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "youtube-quickstart-ruby-credentials.yaml")

# SCOPE FOR WHICH THIS SCRIPT REQUESTS AUTHORIZATION
SCOPE = Google::Apis::YoutubeV3::AUTH_YOUTUBE_READONLY

# @api_key=AIzaSyDhEGNETD_JDvsU8H8tlOy9NZi3fgLJAIA

# @client_id=754910998221-eqsc6ba2lm2nfm8df9a1vt2eodcuk85p.apps.googleusercontent.com

# @client_secret=JoyVtt4ZAYR6XkogEM0bN0fz

def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: REDIRECT_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: REDIRECT_URI)
  end
  credentials
end

# Initialize the API
service = Google::Apis::YoutubeV3::YouTubeService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize


# Sample ruby code for channels.list

def search_list_by_keyword(service, part, **params)
  params = params.delete_if { |p, v| v == ''}
  response = service.list_searches(part, params)

end


def channels_list_by_id(service, part, **params)
  params = params.delete_if { |p, v| v == ''}
  response = service.list_channels(part, params)

end


def video_categories_list(service, part, **params)
  params = params.delete_if { |p, v| v == ''}
  response = service.list_video_categories(part, params)
  # print_results(response)
end


def videos_list_most_popular(service, part, **params)
  params = params.delete_if { |p, v| v == ''}
  response = service.list_videos(part, params)
  # print_results(response)
end


def channels_list_by_username(service, part, **params)

  response = service.list_channels(part, params).to_json

  item = JSON.parse(response).fetch("items")[0]

  puts ("This channel's ID is #{item.fetch("id")}. " +
        "Its title is '#{item.fetch("snippet").fetch("title")}', and it has " +
        "#{item.fetch("statistics").fetch("viewCount")} views.")
end

def comment_threads_list_by_video_id(service, part, **params)
  params = params.delete_if { |p, v| v == ''}
  response = service.list_comment_threads(part, params)
  # print_results(response)
end

def videos_list_by_id(service, part, **params)
  params = params.delete_if { |p, v| v == ''}
  response = service.list_videos(part, params)
  # print_results(response)
end


@video_search = videos_list_by_id(service, 'snippet,contentDetails,statistics',
  id: 'Ks-_Mh1QhMc')


@comments = comment_threads_list_by_video_id(service, 'snippet,replies',
  video_id: 'Ks-_Mh1QhMc')

binding.pry

# channels_list_by_username(service, 'snippet,contentDetails,statistics', for_username: 'GoogleDevelopers')

# @keyword_response=search_list_by_keyword(service, 'snippet',
#   max_results: 25,
#   q: 'movies',
#   type: '')

# binding.pry


# @popular_videos=videos_list_most_popular(service, 'snippet,contentDetails,statistics',
#   chart: 'mostPopular',
#   region_code: 'US',
#   video_category_id: '')

# @video_categories=video_categories_list(service, 'snippet',
#   region_code: 'US')

# @channel_details = channels_list_by_id(service, 'snippet,contentDetails,statistics',
#   id: @keyword_response.items[1].snippet.channel_id)