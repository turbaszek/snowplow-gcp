FROM snowplow-docker-registry.bintray.io/snowplow/snowplow-bigquery-loader:0.5.1

COPY entrypoint.sh /config/entrypoint.sh

RUN chmod +x /config/entrypoint.sh

ENTRYPOINT ["sh", "/config/entrypoint.sh"]
