sudo apt-get -y install \
     autoconf \
     bison \
     build-essential \
     curl \
     git-core \
     libapr1 \
     libaprutil1 \
     libcurl4-openssl-dev \
     libgmp3-dev \
     libpcap-dev \
     libpq-dev \
     libreadline6-dev \
     libsqlite3-dev \
     libssl-dev \
     libsvn1 \
     libtool \
     libxml2 \
     libxml2-dev \
     libxslt-dev \
     libyaml-dev \
     locate \
     ncurses-dev \
     openssl \
     postgresql \
     postgresql-contrib \
     wget \
     xsel \
     zlib1g \
     zlib1g-dev

curl -sSL https://rvm.io/mpapis.asc | gpg --import -

curl -L https://get.rvm.io | bash -s stable

source ~/.rvm/scripts/rvm

rvm --install $(cat .ruby-version)

gem install bundler

bundle install
