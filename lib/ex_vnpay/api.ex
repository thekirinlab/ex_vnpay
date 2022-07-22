defmodule ExVnpay.API do
  @moduledoc """
  Utilities for interacting with the ExVnpay API v1.1.
  """

  alias ExVnpay.{Config, Request}

  @api_path "https://acuityscheduling.com/api/v1"

  @type method :: :get | :post | :put | :delete | :patch
  @type headers :: %{String.t() => String.t()} | %{}
  @type body :: iodata() | {:multipart, list()}

  @request_module if Mix.env() == :test, do: Acuity.RequestMock, else: Request

  def pay(amount, params \\ %{}) do
    # vnp_Amount=1806000&vnp_Command=pay&vnp_CreateDate=20210801153333&vnp_CurrCode=VND&vnp_IpAddr=127.0.0.1&vnp_Locale=vn&vnp_OrderInfo=Thanh+toan+don+hang+%3A5&vnp_OrderType=other&vnp_ReturnUrl=https%3A%2F%2Fdomainmerchant.vn%2FReturnUrl&vnp_TmnCode=DEMOV210&vnp_TxnRef=5&vnp_Version=2.1.0&vnp_SecureHash=3e0d61a0c0534b2e36680b3f7277743e8784cc4e1d68fa7d276e79c23be7d6318d338b477910a27992f5057bb1582bd44bd82ae8009ffaf6d141219218625c42
    params = %{
      "vnp_Amount" => amount * 100,
      "vnp_Command" => "pay",
      "vnp_CurrCode" => "VND"
    }

    encoded_query = URI.encode_query(params)

    request("vpcpay.html?#{encoded_query}", :get)
  end

  defp api_path do
    if Config.production() do
    else
      "https://sandbox.vnpayment.vn/paymentv2/"
    end
  end

  @spec add_default_headers(headers) :: headers
  defp add_default_headers(headers) do
    Map.merge(
      %{
        Accept: "application/json; charset=utf8",
        "Content-Type": "application/json"
      },
      headers
    )
  end

  # @spec add_auth_header(headers) :: headers
  # defp add_auth_header(headers) do
  #   Map.put(headers, "Authorization", "Bearer #{Config.access_token()}")
  # end

  @spec request(String.t(), method, body, headers, list) ::
          {:ok, map} | {:error, any()}
  def request(path, method, body \\ "", headers \\ %{}, opts \\ []) do
    req_url = build_path(path)

    # hackney: [basic_auth: {Config.user_id(), Config.api_key()}],

    opts = [
      hackney: [basic_auth: {Config.user_id(), Config.api_key()}]
    ]

    req_headers =
      headers
      |> add_default_headers()
      # |> add_auth_header()
      |> Map.to_list()

    encoded_body = encode_body(body, method, req_headers)

    @request_module.request(method, req_url, encoded_body, req_headers, opts)
  end

  defp encode_body(body, method, req_headers) do
    if method != :get && Keyword.get(req_headers, :"Content-Type") == "application/json" do
      Config.json_library().encode!(body)
    else
      body
    end
  end

  defp build_path(path) do
    if String.starts_with?(path, "/") do
      "#{api_path()}#{path}"
    else
      "#{api_path()}/#{path}"
    end
  end
end
