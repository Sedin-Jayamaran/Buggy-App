FROM ruby-3.3.8v1
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3
COPY . .
RUN bundle exec rake assets:precompile
EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
