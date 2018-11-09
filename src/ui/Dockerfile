FROM alpine:3.7 AS build
ENV APP_RUNTIME /app_runtime
RUN apk add g++ \
            make \
            ruby \
            ruby-dev && \
    mkdir -p $APP_RUNTIME && \
    gem install bundler --no-ri --no-rdoc 

WORKDIR $APP_RUNTIME
COPY Gemfile* $APP_RUNTIME/
RUN bundle install --jobs 4 --deployment --binstubs --standalone && \
    rm vendor/bundle/ruby/2.4.0/cache/*

FROM alpine:3.7
LABEL version="logging"
ENV APP_RUNTIME /app_runtime
ENV APP_HOME /app
RUN apk add --no-cache ruby
COPY --from=build $APP_RUNTIME $APP_RUNTIME
COPY . $APP_HOME
WORKDIR $APP_HOME
ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

CMD ["/app_runtime/bin/puma"]
