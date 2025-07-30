FROM 156916773321.dkr.ecr.ap-south-1.amazonaws.com/jayamaran/sample-for-ecs:base
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3
COPY . .

RUN RAILS_ENV=production bundle exec rails assets:precompile
 
EXPOSE 3000
 
CMD ["bash", "-c", "bundle exec rails db:migrate && rails server -b 0.0.0.0"]
