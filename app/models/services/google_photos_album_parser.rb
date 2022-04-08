module Services
  class GooglePhotosAlbumParser

    DEFAULT_MAX_RESULTS = 5000

    def initialize(owner, title, max_results = DEFAULT_MAX_RESULTS)
      @owner = owner
      @title = title
      @max_results = max_results
    end

    def album
      @album ||= _album
    end

    def album_id
      @album_id ||= albums['albums'].select { |a| a['title'] == @title }.first['id']
    end

    def albums
      @albums ||= _albums
    end

    def content
      @content ||= album.map do |media|
        Hashie::Mash.new({ url: media['baseUrl'], external_created_at: media['mediaMetadata']['creationTime'], type: media['mimeType'] })
      end
    end

    private

    def refresh_token
      url = 'https://oauth2.googleapis.com/token'
      res = HTTParty.post(url,
                          query: {
                            "refresh_token": @owner.refresh_token,
                            "client_id": ENV['GOOGLE_CLIENT_ID'],
                            "client_secret": ENV['GOOGLE_CLIENT_SECRET'],
                            "grant_type": 'refresh_token'
                          })
      @owner.access_token = res['access_token']
      @owner.expires_at = Time.now.to_i + res['expires_in']
      @owner.save && true
    end

    def validate_token
      return unless @owner.present?
      return true if @owner.expires_at >= Time.now.to_i

      refresh_token
    end

    def _albums
      validate_token && HTTParty.get('https://photoslibrary.googleapis.com/v1/albums',
                                     "query": { "access_token": @owner.access_token })
    end

    def _album
      cursor = nil
      album = []
      id = album_id
      return unless album_id

      loop do
        validate_token
        res = HTTParty.post('https://photoslibrary.googleapis.com/v1/mediaItems:search',
                            "query": { "access_token": @owner.access_token, "pageSize": '100', "albumId": id,
                                       "pageToken": cursor }
        )
        cursor = res['nextPageToken']
        album += res['mediaItems']
        break if album.count >= @max_results || cursor.nil?
      rescue StandardError
        break
      end
      album
    end

  end
end
