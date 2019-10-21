# Docker公式のRubyイメージを使う
FROM ruby:2.6.1-stretch

# アプリケーションを配置するディレクトリ
WORKDIR /app

# Node.jsのv10系列とYarnの安定版をインストールする
RUN curl -sSfL https://deb.nodesource.com/setup_10.x | bash - \
    && curl -sSfL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y \
       nodejs \
       yarn \
    && rm -rf /var/lib/apt/lists/*

# Bundlerでgemをインストールする
ARG BUNDLE_INSTALL_ARGS="-j 4"
COPY Gemfile Gemfile.lock ./
RUN bundle config --local disable_platform_warnings true \
    && bundle install ${BUNDLE_INSTALL_ARGS}

# YarnでNodeパッケージをインストールする
COPY package.json yarn.lock ./
RUN yarn install

# nodeのイメージからNode.jsとYarnをコピーする
COPY --from=node:10.15.3-stretch /usr/local/ /usr/local/
COPY --from=node:10.15.3-stretch /opt/ /opt/

# エントリポイントを設定する
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# アプリケーションのファイルをコピーする
COPY . ./

# サービスを実行するコマンドとポートを設定する
CMD ["rails", "server", "-b", "0.0.0.0"]
EXPOSE 3000

