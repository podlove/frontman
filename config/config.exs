# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :frontman,
  ecto_repos: [Frontman.Repo]

# Configures the endpoint
config :frontman, FrontmanWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "68YTYD4Vsrryz6iH9oIcWDh+8Es2kPq5ModvkL3H1OgH38FfVMFmsv+73eAUANyr",
  render_errors: [view: FrontmanWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Frontman.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :frontman, Frontman.UserManager.Guardian,
  issuer: "frontman",
  secret_key: "nhywU8VOY/EKENwfEgsM8HxXkeqnf2dFn+hLnQJunXtteqwinjep50k+zKwBbeR7"

config :frontman, Frontman.Scheduler,
  overlap: false,
  jobs: [
    refresh_cache: [
      schedule: "*/3 * * * *",
      task: {Frontman.Directory.Refresher, :refresh, []}
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
