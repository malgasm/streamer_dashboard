FROM archlinux

RUN pacman -Syu --noconfirm && pacman -S --noconfirm git python base-devel

ENV NODE_VERSION=10.22.0
ENV EMBER_ENV=production

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
RUN source ~/.nvm/nvm.sh && nvm install $NODE_VERSION && nvm alias default $NODE_VERSION && nvm use default && echo "source ~/.nvm/nvm.sh" >> ~/.bash_profile

RUN source ~/.nvm/nvm.sh && yes | npm install -g yarn

ADD . /app
WORKDIR /app
RUN source ~/.nvm/nvm.sh && \
  npm install -g yarn ember-cli node-gyp && \
  yarn && \
  ember build -e $EMBER_ENV

EXPOSE 4200
ENV PATH=/root/.nvm/versions/node/v$NODE_VERSION/bin:$PATH

ENV EMBER_ENV="${EMBER_ENV:-test}"
CMD ["ember", "serve", "-e", "$EMBER_ENV"]
