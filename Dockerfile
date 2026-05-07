FROM alpine:latest

WORKDIR /app

COPY scripts/bootstrap.sh /app/bootstrap.sh

RUN chmod +x /app/bootstrap.sh

CMD ["/app/bootstrap.sh"]
