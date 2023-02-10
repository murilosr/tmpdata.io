defmodule TmpDataIOWeb.UI.GoogleAnalyticsTest do
	use ExUnit.Case, async: false
	doctest TmpDataIOWeb.UI.GoogleAnalytics
	alias TmpDataIOWeb.UI.GoogleAnalytics

  @g_tag "G-123456-TEST"

  defp put_application_env_for_test(app, key, value) do
    previous_value = Application.get_env(app, key)
    Application.put_env(app, key, value)
    on_exit(fn -> Application.put_env(app, key, previous_value) end)
  end

  defp set_google_valid_analytics_tag(context) do put_application_env_for_test(:tmpdata_io, GoogleAnalytics, tag_id: @g_tag) end
  defp set_google_empty_analytics_tag(context) do put_application_env_for_test(:tmpdata_io, GoogleAnalytics, tag_id: nil) end

  describe "google analytics without setup config" do
    test "header must return empty string", _context do
      assert GoogleAnalytics.header() == ""
    end

    test "script must return empty string", _context do
      assert GoogleAnalytics.script() == ""
    end
  end

  describe "google analytics with nil setup config" do
    setup [:set_google_empty_analytics_tag]

    test "header must return empty string", _context do
      assert GoogleAnalytics.header() == ""
    end

    test "script must return empty string", _context do
      assert GoogleAnalytics.script() == ""
    end
  end

  describe "google analytics with valid setup config" do
    setup [:set_google_valid_analytics_tag]

    test "header must return script tag", _context do
      assert GoogleAnalytics.header() =~ "src=\"https://www.googletagmanager.com/gtag/js?id=#{@g_tag}\""
      assert GoogleAnalytics.header() =~ "</script>"
    end

    test "script must return script tag", _context do
      assert GoogleAnalytics.script() =~ "gtag('config', '#{@g_tag}')"
      assert GoogleAnalytics.script() =~ "</script>"
    end
  end

end
