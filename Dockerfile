# syntax=docker/dockerfile:1

# Base stage for shared settings and dependencies
FROM ruby:3.2.2-slim as base

# Environment variables for Rails to run in production
ENV RAILS_ENV=development \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    RUBY_VERSION=3.2.2

# Rails app directory
WORKDIR /rails

# Build stage for installing temporary build dependencies and building gems
FROM base as build

# System dependencies needed for building native extensions
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libvips \
    pkg-config \
    libyaml-dev && \
    rm -rf /var/lib/apt/lists/*

# Install gems using Bundler
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test && \
    rm -rf ~/.bundle "${BUNDLE_PATH}/cache" "${BUNDLE_PATH}/gems/*/cache" "${BUNDLE_PATH}/gems/*/.git"

# Copy the application code into the image
COPY . .

# Precompile assets and bootsnap for faster boot times
RUN bundle exec bootsnap precompile app/ lib/ && \
    chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# Final stage for the application image
FROM base

# Install runtime dependencies
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    curl \
    libsqlite3-0 \
    libvips \
    libyaml-0-2 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Copy artifacts from the build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Add a non-root user for running the application
RUN useradd -m -s /bin/bash rails && chown -R rails:rails /rails
USER rails

# Copy and set permissions for the entrypoint script
COPY bin/docker-entrypoint /rails/bin/docker-entrypoint.sh
USER root
RUN chown rails /rails/bin/docker-entrypoint.sh
USER rails
RUN chmod +x /rails/bin/docker-entrypoint.sh

# Set the entrypoint script to run on container start
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port 3000 for the Rails server
EXPOSE 3001

# Start the Rails server by default
CMD ["./bin/rails", "server"]
