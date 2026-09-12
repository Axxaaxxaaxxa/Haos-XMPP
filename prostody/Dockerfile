ARG BUILD_FROM
FROM prosody/prosody:latest

RUN apt-get update && apt-get install -y \
    lua-sec \
    lua-event \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

CMD ["/run.sh"]
