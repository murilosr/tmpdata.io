defmodule TmpDataIOWeb.UI.GoogleAnalytics do
  use Phoenix.Component

  defp parse_if_tag_present(html) do
    case Application.get_env(:tmpdata_io, __MODULE__, nil) do
      nil -> ""
      [tag_id: tag_id] when tag_id != nil -> String.replace(html, "{TAG_ID}", tag_id)
      [tag_id: nil] -> ""
    end
  end

  def header() do
    """
    <script async src="https://www.googletagmanager.com/gtag/js?id={TAG_ID}"></script>
    """
    |> parse_if_tag_present()
  end

  def script() do
    """
      <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());

      gtag('config', '{TAG_ID}');
      </script>
    """
    |> parse_if_tag_present()
  end

end
