require "minitest/autorun"
require "jekyll"
require "jekyll-series-links"
require "tmpdir"
require "fileutils"

module JekyllSeriesTestHelper
  # Build a minimal Jekyll site in a temp directory with the given posts.
  #
  # Each post is a Hash with:
  #   :date         - "YYYY-MM-DD"
  #   :slug         - filename slug (e.g. "my-post")
  #   :front_matter - Hash of YAML front matter (must include "title")
  #   :content      - optional body text
  #
  # Options:
  #   includes: { "series_links.html" => "<template>" }
  #
  # Returns a Jekyll::Site that has been read and had the generator run.
  def build_site(posts, includes: {})
    @tmpdir = Dir.mktmpdir("jekyll-series-test")

    posts_dir = File.join(@tmpdir, "_posts")
    FileUtils.mkdir_p(posts_dir)

    posts.each do |post|
      filename = "#{post[:date]}-#{post[:slug]}.md"
      lines = ["---"]
      post[:front_matter].each { |k, v| lines << "#{k}: #{v}" }
      lines << "---"
      lines << (post[:content] || "")
      File.write(File.join(posts_dir, filename), lines.join("\n"))
    end

    if includes.any?
      includes_dir = File.join(@tmpdir, "_includes")
      FileUtils.mkdir_p(includes_dir)
      includes.each do |name, content|
        File.write(File.join(includes_dir, name), content)
      end
    end

    config = Jekyll.configuration(
      "source" => @tmpdir,
      "destination" => File.join(@tmpdir, "_site"),
      "quiet" => true
    )

    site = Jekyll::Site.new(config)
    site.read
    Jekyll::Series::Generator.new.generate(site)
    site
  end

  # Find a post by its slug (the part after the date in the filename).
  def find_post(site, slug)
    site.posts.docs.find { |p| p.basename_without_ext.end_with?(slug) }
  end

  def teardown
    FileUtils.remove_entry_secure(@tmpdir) if @tmpdir && File.exist?(@tmpdir)
  end
end
