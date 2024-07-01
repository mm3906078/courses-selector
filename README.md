# Courses Selection

## Description
This is a simple app for planning course selection. It uses the Etcd database and Elixir backend with Phonix Framework.

## Installation & running
To install the application you need to download the repository and install the requirements. To do this, run the following commands in the terminal:
```
git clone https://github.com/mm3906078/courses-selector.git
cd courses-selector
docker compose up -d
```

If you don't have docker, you can install it by following the instructions on the official website: https://docs.docker.com/get-docker/

If you don't want to use docker, you can install the application using the following commands:

```
git clone https://github.com/mm3906078/courses-selector.git
cd courses-selector/backend
mix deps.get
iex -S mix phx.server
```

Of course, you need to install Elixir and Erlang on your system. You can install them by following the instructions on the official website: https://elixir-lang.org/install.html

## Setup env file

TODO: GET ENV.

## Usage

You can access the application Swagger by following the link: http://localhost:4000/swaggerui#/

## Development
```
docker compose up -d --force-recreate --no-deps --build
```
