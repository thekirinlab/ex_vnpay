defmodule ExVnpay.Request do
  @moduledoc """
  Utilities to send request to ExVnpay API v1.1
  """

  alias HTTPoison.{Error, Response}
  require Logger

  alias ExVnpay.Config

  @default_opts [
    timeout: 15_000,
    recv_timeout: 15_000
  ]

  @callback request(String.t(), String.t(), any(), list, list) :: {:ok, map} | {:error, any()}
  def request(method, req_url, body, req_headers, opts \\ @default_opts) do
    Logger.debug(req_url)

    HTTPoison.request(method, req_url, body, req_headers, opts)
    |> handle_response()
  end

  defp handle_response({:ok, %Response{body: body, status_code: code}})
       when code in 200..299 do
    Logger.debug("body: #{inspect(body)}")

    decoded_body =
      case body do
        "" -> ""
        _ -> Config.json_library().decode!(body)
      end

    {:ok, decoded_body}
  end

  defp handle_response({:ok, %Response{body: body, status_code: _, request_url: request_url}}) do
    Logger.error(inspect(body))
    Logger.error(inspect(request_url))
    {:error, body}
  end

  defp handle_response({:error, %Error{} = error}),
    do: {:error, error}
end
