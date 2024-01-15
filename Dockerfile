FROM ubuntu:23.10

RUN rm -f /etc/apt/apt.conf.d/docker-clean && \
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/keep-cache

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked,id=apt \
    apt update && \
    apt install -y --no-install-recommends freeradius

# in ubuntu raddb lives in /etc/freeradius/3.0, we just ignore it, but you can
# refer there if you want

COPY conf /conf
WORKDIR /conf

CMD ["/usr/sbin/freeradius", "-f", "-X", "-d", "/conf"]
