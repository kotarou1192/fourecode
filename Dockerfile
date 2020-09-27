FROM ruby:2.7.1
RUN apt-get update -qq && apt-get install -y postgresql-client
RUN mkdir /fourecode
WORKDIR /fourecode
COPY Gemfile /fourecode/Gemfile
COPY Gemfile.lock /fourecode/Gemfile.lock
RUN bundle install
COPY . /fourecode

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
