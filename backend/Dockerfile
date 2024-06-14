# Use the official Elixir image as the base image
FROM elixir:1.15-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the mix.exs and mix.lock files to the container
COPY mix.exs mix.lock ./

# Install the dependencies
RUN mix do deps.get, deps.compile

# Copy the rest of the application code to the container
COPY . .

# Compile the application
RUN mix compile

# Set the default command to start the application
CMD ["mix", "run", "--no-halt"]
