# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3.3
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

WORKDIR /rails

# Install base system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Set production environment variables
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    BUNDLE_FROZEN="false"

# Build stage
FROM base AS build

# Install build dependencies
# Install necessary packages for Nokogiri and other gems
# Install necessary system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      git \
      curl \
      pkg-config \
      libxml2-dev \
      libxslt1-dev \
      liblzma-dev \
      libcurl4-openssl-dev \
      libssl-dev && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*



# Install Bundler
RUN gem install bundler -v 2.5.23

# Copy application dependencies
COPY Gemfile Gemfile.lock ./

# Ensure Gemfile.lock is not frozen
RUN bundle config set frozen false

# Update net-pop separately to avoid dependency conflicts
RUN bundle update net-pop

# Install gems
RUN bundle install

# Debugging: Check if gems are installed
RUN bundle list

# Cleanup (Separate cleanup to isolate potential issues)
RUN rm -rf ~/.bundle/
RUN rm -rf /usr/local/bundle/ruby/*/cache
RUN rm -rf /usr/local/bundle/ruby/*/bundler/gems/*/.git

# Precompile Bootsnap
RUN bundle exec bootsnap precompile --gemfile

# Verify Rails installation
RUN bundle exec rails --version

# Copy application code
COPY . /rails

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile


# Final app image
FROM base

# Copy built artifacts
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Verify the Rails executable is copied
RUN ls -l /rails/bin/rails

# Run as non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /rails/db /rails/log /rails/storage /rails/tmp

USER rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the Rails server
EXPOSE 80
CMD ["bundle", "exec", "/rails/bin/rails", "server", "-b", "0.0.0.0"]
