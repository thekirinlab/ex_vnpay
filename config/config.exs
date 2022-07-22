use Mix.Config

# for testing with real access token
config :ex_vnpay,
  user_id: {:system, "VNP_TMN_CODE"},
  api_key: {:system, "VNP_HASH_SECRET_KEY"},
  production: false
