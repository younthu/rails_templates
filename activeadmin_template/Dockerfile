FROM ruby:2.6.3
# https://rubyinrails.com/2019/03/29/dockerify-rails-6-application-setup/
# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs ghostscript
RUN apt install -y vim

RUN mkdir -p /var/www
RUN mkdir -p /usr/local/nvm
WORKDIR /var/www

RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y nodejs

# npm 换成淘宝源
#RUN npm install -g cnpm --registry=https://registry.npm.taobao.org

RUN node -v
RUN npm -v

# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile Gemfile.lock package.json yarn.lock /tmp/
WORKDIR /tmp
RUN gem install bundler -v 1.17.2
#RUN gem install foreman -v 0.85.0
RUN bundle install --verbose --jobs 20 --retry 5

# === SSH ===
# add sshd
RUN rm -f /etc/service/sshd/down

RUN ssh-keygen -t rsa -q -f "$HOME/.ssh/id_rsa" -N ""
## Install an SSH of your choice.
RUN rm -f /root/.ssh/authorized_keys
ADD config/docker/ssh/sshkey.pub /tmp/your_key.pub
#RUN cat /tmp/your_key.pub >> /root/.ssh/authorized_keys && cat /tmp/your_key.pub >> /home/app/.ssh/authorized_keys && rm -f /tmp/your_key.pub
RUN cat /tmp/your_key.pub >> /root/.ssh/authorized_keys && rm -f /tmp/your_key.pub
## copy key of container
RUN rm -f /root/.ssh/id_rsa && \
    rm -f /root/.ssh/id_rsa.pub && \
    rm -f /home/app/.ssh/id_rsa &&  \
    rm -f /home/app/.ssh/id_rsa.pub
ADD config/docker/ssh/root_key /root/.ssh/id_rsa
ADD config/docker/ssh/root_key.pub /root/.ssh/id_rsa.pub
#ADD config/docker/ssh/root_key /home/app/.ssh/id_rsa
#ADD config/docker/ssh/root_key.pub /home/app/.ssh/id_rsa.pub
#RUN chown -R app:app /home/app/.ssh/ && \
#    chmod 600 /root/.ssh/id_rsa /home/app/.ssh/id_rsa && \
#    chmod 644 /root/.ssh/id_rsa.pub /home/app/.ssh/id_rsa.pub


RUN npm install -g yarn
RUN yarn install --check-files

RUN apt install -y openssh-server

# install tzdata
RUN apt-get install tzdata
# install mediainfo
RUN apt-get install -y mediainfo

WORKDIR /var/www
# Copy the main application.
COPY . ./

COPY config/docker/docker-entrypoint.sh /usr/local/bin/
RUN chmod 777 /usr/local/bin/docker-entrypoint.sh && ln -s /usr/local/bin/docker-entrypoint.sh / # backwards compat
#ENTRYPOINT ["docker-entrypoint.sh"]

# Expose port 3000 to the Docker host, so we can access it
# from the outside.
EXPOSE 3000

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
#CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"] # 只在第一次运行的时候执行, docker run的时候执行
CMD ["/usr/local/bin/docker-entrypoint.sh"] # 在docker run和docker start的时候都执行
#CMD ["./start.sh"]