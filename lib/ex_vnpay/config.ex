defmodule ExVnpay.Config do
  @moduledoc """
  Utility that handles interaction with the application's configuration
  """

  @doc """
  In config.exs your implicit or expicit configuration is:
      config :ex_vnpay, json_library: Poison # defaults to Jason but can be configured to Poison
  """
  @spec json_library() :: module
  def json_library do
    resolve(:json_library, Jason)
  end

  @doc """
  In config.exs, use a string, a function or a tuple:
      config :ex_vnpay, vnp_tmn_code: System.get_env("VNP_TMN_CODE")

  or:
      config :ex_vnpay, vnp_tmn_code: {:system, "VNP_TMN_CODE"}

  or:
      config :ex_vnpay, vnp_tmn_code: {MyApp.Config, :vnp_tmn_code, []}
  """
  def vnp_tmn_code do
    resolve(:vnp_tmn_code, System.get_env("VNP_TMN_CODE"))
  end

  @doc """
  In config.exs, use a string, a function or a tuple:
      config :ex_vnpay, vnp_hash_secret_key: System.get_env("VNP_HASH_SECRET_KEY")

  or:
      config :ex_vnpay, vnp_hash_secret_key: {:system, "VNP_HASH_SECRET_KEY"}

  or:
      config :ex_vnpay, vnp_hash_secret_key: {MyApp.Config, :VNP_HASH_SECRET_KEY, []}
  """
  def vnp_hash_secret_key do
    resolve(:vnp_hash_secret_key, System.get_env("VNP_HASH_SECRET_KEY"))
  end

  def production do
    resolve(:production, !!System.get_env("VNP_PRODUCTION"))
  end

  @doc """
  Resolves the given key from the application's configuration returning the
  wrapped expanded value. If the value was a function it get's evaluated, if
  the value is a touple of three elements it gets applied.
  """
  @spec resolve(atom, any) :: any
  def resolve(key, default \\ nil)

  def resolve(key, default) when is_atom(key) do
    Application.get_env(:ex_vnpay, key, default)
    |> expand_value()
  end

  def resolve(key, _) do
    raise(
      ArgumentError,
      message: "#{__MODULE__} expected key '#{key}' to be an atom"
    )
  end

  defp expand_value({:system, env})
       when is_binary(env) do
    System.get_env(env)
  end

  defp expand_value({module, function, args})
       when is_atom(function) and is_list(args) do
    apply(module, function, args)
  end

  defp expand_value(value) when is_function(value) do
    value.()
  end

  defp expand_value(value), do: value
end
