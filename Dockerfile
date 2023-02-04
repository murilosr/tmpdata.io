FROM alpine:latest

RUN apk update
RUN apk add elixir
RUN apk add erlang-dev

RUN mkdir /app/
RUN cd /app/
COPY . .

ENV PORT=4000
ENV MIX_ENV=prod

RUN yes | mix deps.get --only prod
RUN yes | mix compile
RUN mix assets.deploy

CMD ["mix", "phx.server"]