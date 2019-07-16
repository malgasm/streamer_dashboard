defmodule SoundboardWeb.NukaCrypt do
  require Logger

  def get_nukacrypt_codes do
    fetch_nukacrypt_source
      |> parse_nukacrypt_source
      |> extract_codes
  end

  def get_nukacrypt_code_text do
    [alpha, bravo, charlie] = get_nukacrypt_codes
    "ALPHA: #{alpha} BRAVO: #{bravo} CHARLIE: #{charlie}"
  end

  defp fetch_nukacrypt_source do
    :httpc.request(:get, {'https://nukacrypt.com', []}, [], [])
  end

  defp parse_nukacrypt_source({:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, body}} ), do: body

  defp parse_nukacrypt_source({:error, _}) do
    #todo: send a message indicating that there was an error
  end

  defp extract_codes(parsed_source) do
    html_body = Floki.parse(parsed_source)
    codes = Floki
      .find(html_body, "#nuclearcodes tr:last-child td")
      |> Enum.map(fn({"td", [], [code]}) -> code end)
  end
end
