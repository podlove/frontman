import Config

config :frontman, FrontmanWeb.Endpoint,
  http: [:inet6, port: System.fetch_env!("PORT")],
  url: [host: System.fetch_env!("HOST"), port: System.fetch_env!("PUBLIC_PORT")]

config :frontman, Frontman.Repo,
  username: System.fetch_env!("POSTGRES_USER"),
  password: System.fetch_env!("POSTGRES_PASSWORD"),
  database: System.fetch_env!("POSTGRES_DATABASE"),
  hostname: System.fetch_env!("POSTGRES_HOST")
