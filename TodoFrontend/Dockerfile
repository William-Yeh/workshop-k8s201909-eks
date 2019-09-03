#
# http static server one-liners
#

FROM busybox:1.30

WORKDIR /app
COPY . .

# Fix permission for Windows + Skaffold users
# @see https://william-yeh.net/post/2019/06/docker-file-permissions/
RUN chmod +x run.sh


# Configurable host:port - location of backend todoapi server
ENV TODOAPI_HOST localhost
ENV TODOAPI_PORT 30080

EXPOSE 80
CMD ["./run.sh"]
