ARG MIX_ENV="prod"

FROM hexpm/elixir:1.12.2-erlang-24.1.4-alpine-3.13.6 as build
RUN apk add --no-cache build-base git python3 curl
WORKDIR /app
RUN mix local.hex --force && \
    mix local.rebar --force
ARG MIX_ENV
ENV MIX_ENV="${MIX_ENV}"
COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config
COPY config/config.exs config/$MIX_ENV.exs config/
RUN mix deps.compile
COPY priv priv
COPY assets assets
RUN mix assets.deploy
COPY lib lib
RUN mix compile
COPY config/runtime.exs config/
RUN mix release

FROM alpine:3.13.6 AS app
RUN apk add --no-cache libstdc++ openssl ncurses-libs
ARG MIX_ENV
ENV USER="elixir"
WORKDIR "/home/${USER}/app"
RUN \
  addgroup \
   -g 1000 \
   -S "${USER}" \
  && adduser \
   -s /bin/sh \
   -u 1000 \
   -G "${USER}" \
   -h "/home/${USER}" \
   -D "${USER}" \
  && su "${USER}"
USER "${USER}"
COPY --from=build --chown="${USER}":"${USER}" /app/_build/"${MIX_ENV}"/rel/tartu_smarter_bike ./
ENTRYPOINT ["bin/tartu_smarter_bike"]
CMD ["start"]

