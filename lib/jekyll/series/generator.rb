module Jekyll
  module Series
    class Generator < Jekyll::Generator
      safe true
      priority :low

      def generate(site)
        series_groups = {}

        site.posts.docs.each do |post|
          series_name = post.data["series"]
          next unless series_name

          series_groups[series_name] ||= []
          series_groups[series_name] << post
        end

        series_groups.each do |series_name, posts|
          sorted = posts.sort_by { |p| [p.data["series_part"]&.to_i || p.date, p.data["title"].to_s] }

          sorted.each_with_index do |p, i|
            p.data["series_part"] ||= i + 1
          end

          series_data = sorted.map do |p|
            {
              "title" => p.data["title"],
              "url" => p.url,
              "part" => p.data["series_part"].to_i
            }
          end

          sorted.each do |post|
            post.data["series_posts"] = series_data
          end
        end
      end
    end
  end
end
