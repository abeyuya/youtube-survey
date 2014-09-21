# encoding: utf-8
#!/usr/bin/ruby

require 'google/api_client'
require 'yaml'
require 'pp'

DEFINE = YAML::load(File.open('config/define.yml'))

class GoogleClient

  def self.create_client

    client = Google::APIClient.new(:application_name => 'youtube-survey')
    key = Google::APIClient::PKCS12.load_key('config/youtube-survey-key.p12', 'notasecret')
    client.authorization = Signet::OAuth2::Client.new(
      :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
      :audience             => 'https://accounts.google.com/o/oauth2/token',
      :scope                => 'https://www.googleapis.com/auth/youtube',
      :issuer               => DEFINE['issuer'],
      :signing_key          => key
    )
    client.authorization.fetch_access_token!
    youtube = client.discovered_api('youtube', 'v3')

    return client, youtube
  end

  def search_video

    google_client, youtube_client = GoogleClient.create_client

    search_response_json = google_client.execute!(
      :api_method => youtube_client.search.list,
      :parameters => {
        :part => 'snippet',
        :q => 'google',
        :maxResults => 25
      }
    )

    search_result = JSON.parse(search_response_json.response.body)
    pp search_result
  end

end
