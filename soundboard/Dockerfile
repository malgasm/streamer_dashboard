FROM archlinux:latest

SHELL ["/bin/bash", "--login", "-c"]

RUN pacman --noconfirm -Sy && pacman --noconfirm -S elixir sudo git make net-tools iputils iproute2 net-tools

ENV SDUSER=streamerdashboard

RUN groupadd --gid 1000 streamerdashboard \
    && useradd --uid 1000 --gid $SDUSER --shell /bin/bash --create-home $SDUSER

# RUN mkdir /var/log/streamer_dashboard && chmod 777 -R /var/log/streamer_dashboard

ADD . /app
WORKDIR /app

RUN echo "streamerdashboard    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers
RUN sudo chown -R streamerdashboard /app

USER $SDUSER

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --force

EXPOSE 4000
CMD ["mix", "phx.server"]
