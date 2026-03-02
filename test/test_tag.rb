require "test_helper"

class TestSeriesLinksTag < Minitest::Test
  include JekyllSeriesTestHelper

  def test_returns_empty_string_when_no_series_posts
    site = build_site([
      { date: "2024-01-01", slug: "no-series",
        front_matter: { "title" => "No Series", "layout" => "post" } }
    ])

    post = find_post(site, "no-series")
    output = render_tag(site, post)

    assert_equal "", output
  end

  def test_renders_default_nav_with_all_parts
    site = build_site([
      { date: "2024-01-01", slug: "part-one",
        front_matter: { "title" => "Part One", "series" => "My Series", "series_part" => 1 } },
      { date: "2024-01-02", slug: "part-two",
        front_matter: { "title" => "Part Two", "series" => "My Series", "series_part" => 2 } }
    ])

    post = find_post(site, "part-one")
    output = render_tag(site, post)

    assert_includes output, "<nav class=\"series-nav\">"
    assert_includes output, "<h4>Series: My Series</h4>"
    assert_includes output, "Part 1: Part One"
    assert_includes output, "Part 2: Part Two"
    assert_includes output, "<ol>"
  end

  def test_current_post_is_bold_not_link
    site = build_site([
      { date: "2024-01-01", slug: "part-one",
        front_matter: { "title" => "Part One", "series" => "My Series", "series_part" => 1 } },
      { date: "2024-01-02", slug: "part-two",
        front_matter: { "title" => "Part Two", "series" => "My Series", "series_part" => 2 } }
    ])

    post = find_post(site, "part-one")
    output = render_tag(site, post)

    assert_includes output, '<li class="series-nav-item series-nav-current"><strong>Part 1: Part One</strong></li>'
    assert_includes output, '<a href='
    refute_includes output, "<a href=\"#{post.url}\">Part 1: Part One</a>"
  end

  def test_other_posts_are_links
    site = build_site([
      { date: "2024-01-01", slug: "part-one",
        front_matter: { "title" => "Part One", "series" => "My Series", "series_part" => 1 } },
      { date: "2024-01-02", slug: "part-two",
        front_matter: { "title" => "Part Two", "series" => "My Series", "series_part" => 2 } }
    ])

    post = find_post(site, "part-one")
    part_two = find_post(site, "part-two")
    output = render_tag(site, post)

    assert_includes output, "<a href=\"#{part_two.url}\">Part 2: Part Two</a>"
  end

  def test_custom_include_template
    site = build_site(
      [
        { date: "2024-01-01", slug: "part-one",
          front_matter: { "title" => "Part One", "series" => "My Series", "series_part" => 1 } }
      ],
      includes: {
        "series_links.html" => "Custom: {{ series_name }} has {{ series_posts.size }} parts"
      }
    )

    post = find_post(site, "part-one")
    output = render_tag(site, post)

    assert_includes output, "Custom: My Series has 1 parts"
  end

  private

  def render_tag(site, post)
    template = Liquid::Template.parse("{% series_links %}")
    template.render(
      Liquid::Context.new(
        {},
        {},
        { site: site, page: post.data.merge("url" => post.url) }
      )
    )
  end
end
