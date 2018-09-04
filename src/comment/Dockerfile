FROM alpine:3.7 AS build
ENV APP_HOME /app
RUN apk add g++ \
            make \
            ruby \
            ruby-dev && \
    mkdir -p $APP_HOME && \
    gem install bundler --no-ri --no-rdoc 

WORKDIR $APP_HOME
COPY . $APP_HOME
RUN bundle install --jobs 4 --deployment --binstubs --standalone && \
    rm vendor/bundle/ruby/2.4.0/cache/*

FROM alpine:3.7
LABEL version="2.0"
ENV APP_HOME /app
RUN apk add --no-cache ruby
COPY --from=build $APP_HOME $APP_HOME
WORKDIR $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["/app/bin/puma"]
