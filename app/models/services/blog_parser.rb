module Services
  class BlogParser

    def initialize(url = ENV['POST_CONTENT_URL'])
      @url = url
    end

    def posts
      @posts ||= begin
                   format_response(HTTParty.get(@url))
                 rescue StandardError
                   {}
                 end
    end

    private

    class CustomRender < Redcarpet::Render::HTML
      def image(link, title, alt_text)
        %(<img src="#{ENV['POST_IMAGES_URL'] + link}" title="#{title}" alt="#{alt_text}"/>)
      end
    end

    def markdown_to_html(markdown)
      convert = Redcarpet::Markdown.new(CustomRender.new(with_toc_data: true, prettify: true, hard_wrap: true),
                                        autolink: true, tables: true, fenced_code_blocks: true,
                                        lax_spacing: false)

      convert.render(markdown.gsub(/(---)[\S\s]+?(---)/, '').chomp)
    end

    # Metadata extraction (/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m)
    def format_response(posts)
      posts = JSON.parse(posts)
      posts.map do |post|
        Hashie::Mash.new({ content: markdown_to_html(post['content']),
                           metadata: { **post['metadata'] },
                           external_created_at: post['metadata']['created_at'] || post['last_modified'] })
      end
    end
  end
end
