class Media
  include DateConcern

  # Max cache time is 60 minutes since the url's expire then.
  def self.all_with_cache
    Rails.cache.fetch(:google_photos_media, expires_in: 1.minutes) { _content }
  end

  def self.all
    @all ||= _content
  end

  private

  def self._content
    admin = Admin.find_by(email: ENV['ADMIN_EMAIL'])
    return unless admin.present?

    Services::GooglePhotosAlbumParser.new(admin, ENV['MEDIA_ALBUM'])&.content
  end

end