use Mix.Config

# log_format = "$dateT$time [$level]$levelpad $metadata$message\n"

# config :logger, :file_log,
#   path: "./log/#{Mix.env()}.log",
#   format: log_format,
#   metadata: [:tid]

# # config :logger, :console, format: log_format

# # config :logger,
# #   backends: [{LoggerFileBackend, :file_log}],
# #   utc_log: true

config :logger_json,
       :backend,
       json_encoder: Poison,
       metadata: :all

config :logger,
  backends: [LoggerJSON]

if System.get_env("DEBUG") == "true" do
  config :logger, level: :debug
else
  config :logger, level: :info
end

import_config "#{Mix.env()}.exs"
