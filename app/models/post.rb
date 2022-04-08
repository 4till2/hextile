class Post
  include DateConcern

  def self.all_with_cache
    Rails.cache.fetch(:blog_posts_from_gh, expires_in: 1.minutes) { _content }
  end

  def self.all
    @all ||= _content
  end

  private

  def self._content
    Services::BlogParser.new.posts
  end

end
