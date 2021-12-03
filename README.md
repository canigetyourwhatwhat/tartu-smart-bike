# :bike: Tartu Smarter Bike :bike:

## We are live!

The project is up and running at [tartusmarterbike.software](http://tartusmarterbike.software).

## Run in docker compose

To start the project in production mode:

  * Create environment variables file with `cp .env.example .env`
  * Update example environment variables
  * Pull the latest project image with `docker-compose pull`
  * Start the project with `docker-compose up -d`

Now you can visit [`localhost`](http://localhost) from your browser.

## Run without docker compose

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

