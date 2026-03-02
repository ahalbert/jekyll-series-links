require "test_helper"

class TestGenerator < Minitest::Test
  include JekyllSeriesTestHelper

  def test_posts_without_series_are_ignored
    site = build_site([
      { date: "2024-01-01", slug: "no-series",
        front_matter: { "title" => "No Series Post", "layout" => "post" } }
    ])

    post = find_post(site, "no-series")
    assert_nil post.data["series_posts"]
  end

  def test_explicit_series_part_sorting
    site = build_site([
      { date: "2024-01-01", slug: "part-two",
        front_matter: { "title" => "Part Two", "series" => "Ruby Basics", "series_part" => 2 } },
      { date: "2024-01-02", slug: "part-one",
        front_matter: { "title" => "Part One", "series" => "Ruby Basics", "series_part" => 1 } },
      { date: "2024-01-03", slug: "part-three",
        front_matter: { "title" => "Part Three", "series" => "Ruby Basics", "series_part" => 3 } }
    ])

    post = find_post(site, "part-one")
    series = post.data["series_posts"]

    assert_equal 3, series.length
    assert_equal "Part One", series[0]["title"]
    assert_equal "Part Two", series[1]["title"]
    assert_equal "Part Three", series[2]["title"]
    assert_equal 1, series[0]["part"]
    assert_equal 2, series[1]["part"]
    assert_equal 3, series[2]["part"]
  end

  def test_auto_assigned_parts_by_date
    site = build_site([
      { date: "2024-03-01", slug: "third",
        front_matter: { "title" => "Third Post", "series" => "Auto Series" } },
      { date: "2024-01-01", slug: "first",
        front_matter: { "title" => "First Post", "series" => "Auto Series" } },
      { date: "2024-02-01", slug: "second",
        front_matter: { "title" => "Second Post", "series" => "Auto Series" } }
    ])

    first = find_post(site, "first")
    series = first.data["series_posts"]

    assert_equal 3, series.length
    assert_equal "First Post", series[0]["title"]
    assert_equal 1, series[0]["part"]
    assert_equal "Second Post", series[1]["title"]
    assert_equal 2, series[1]["part"]
    assert_equal "Third Post", series[2]["title"]
    assert_equal 3, series[2]["part"]
  end

  def test_date_tiebreaker_alphabetical_by_title
    site = build_site([
      { date: "2024-01-01", slug: "zebra",
        front_matter: { "title" => "Zebra Post", "series" => "Tied" } },
      { date: "2024-01-01", slug: "alpha",
        front_matter: { "title" => "Alpha Post", "series" => "Tied" } }
    ])

    post = find_post(site, "alpha")
    series = post.data["series_posts"]

    assert_equal 2, series.length
    assert_equal "Alpha Post", series[0]["title"]
    assert_equal "Zebra Post", series[1]["title"]
  end

  def test_multiple_series_grouped_independently
    site = build_site([
      { date: "2024-01-01", slug: "ruby-one",
        front_matter: { "title" => "Ruby 1", "series" => "Ruby Basics", "series_part" => 1 } },
      { date: "2024-01-02", slug: "ruby-two",
        front_matter: { "title" => "Ruby 2", "series" => "Ruby Basics", "series_part" => 2 } },
      { date: "2024-01-01", slug: "js-one",
        front_matter: { "title" => "JS 1", "series" => "JS Basics", "series_part" => 1 } }
    ])

    ruby_post = find_post(site, "ruby-one")
    js_post = find_post(site, "js-one")

    assert_equal 2, ruby_post.data["series_posts"].length
    assert_equal 1, js_post.data["series_posts"].length
    assert_equal "Ruby 1", ruby_post.data["series_posts"][0]["title"]
    assert_equal "JS 1", js_post.data["series_posts"][0]["title"]
  end

  def test_series_posts_data_has_correct_fields
    site = build_site([
      { date: "2024-01-01", slug: "my-post",
        front_matter: { "title" => "My Post", "series" => "Test Series", "series_part" => 1 } }
    ])

    post = find_post(site, "my-post")
    entry = post.data["series_posts"][0]

    assert_equal "My Post", entry["title"]
    assert_equal 1, entry["part"]
    assert_includes entry["url"], "my-post"
    assert_equal 3, entry.keys.length, "Expected only title, url, part keys"
  end
end
