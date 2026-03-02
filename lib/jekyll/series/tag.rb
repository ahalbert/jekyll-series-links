module Jekyll
  module Series
    class SeriesLinksTag < Liquid::Tag
      def initialize(tag_name, markup, tokens)
        super
      end

      def render(context)
        site = context.registers[:site]
        page = context.registers[:page]

        series_posts = page["series_posts"]
        return "" unless series_posts

        series_name = page["series"]
        current_url = page["url"]

        include_path = File.join(site.source, "_includes", "series_links.html")
        if File.exist?(include_path)
          template = File.read(include_path)
          context["series_posts"] = series_posts
          context["series_name"] = series_name
          Liquid::Template.parse(template).render(context)
        else
          render_default(series_name, series_posts, current_url)
        end
      end

      private

      def render_default(series_name, series_posts, current_url)
        items = series_posts.map do |post|
          if post["url"] == current_url
            %(<li class="series-nav-item series-nav-current"><strong>Part #{post["part"]}: #{post["title"]}</strong></li>)
          else
            %(<li class="series-nav-item"><a href="#{post["url"]}">Part #{post["part"]}: #{post["title"]}</a></li>)
          end
        end.join("\n    ")

        <<~HTML
          <nav class="series-nav">
            <h4>Series: #{series_name}</h4>
            <ol>
              #{items}
            </ol>
          </nav>
        HTML
      end
    end
  end
end

Liquid::Template.register_tag("series_links", Jekyll::Series::SeriesLinksTag)
