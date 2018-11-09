FROM alpine:3.8 as build
ENV APP_RUNTIME /app_runtime
ENV PKG_PATH venv/lib/python3.6/site-packages
RUN apk add --no-cache  gcc \
                        musl-dev \
                        python3 \
                        python3-dev
WORKDIR $APP_RUNTIME
COPY requirements.txt $APP_RUNTIME/

RUN python3 -m venv venv && \
    source venv/bin/activate && \
    pip install -r $APP_RUNTIME/requirements.txt && \
    rm -r $PKG_PATH/pkg_resources* && \
    rm -r $PKG_PATH/setuptools* && \
    rm -r $PKG_PATH/pip* && \
    find / -name "*.pyc" -delete

FROM alpine:3.8
LABEL version="logging"
ENV APP_RUNTIME /app_runtime
ENV APP_HOME /app

RUN apk add --no-cache python3 && \
    find / -name "*.pyc" -delete

COPY --from=build $APP_RUNTIME $APP_RUNTIME
COPY . $APP_HOME
WORKDIR $APP_HOME

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["python3", "post_app.py"]
