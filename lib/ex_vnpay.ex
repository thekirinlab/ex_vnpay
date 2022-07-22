defmodule ExVnpay do
  @moduledoc """
  Documentation for `ExVnpay`.
  """

  alias ExVnpay.API

  def pay(params) do
    API.pay(params)
  end
end
