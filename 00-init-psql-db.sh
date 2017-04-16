set -o xtrace

DB_PASSWORD=darwish

sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service

cat <<EOF> /tmp/pg-utf8.sql
update pg_database set datallowconn = TRUE where datname = 'template0';
\c template0
update pg_database set datistemplate = FALSE where datname = 'template1';
drop database template1;
create database template1 with template = template0 encoding = 'UTF8';
update pg_database set datistemplate = TRUE where datname = 'template1';
\c template1
update pg_database set datallowconn = FALSE where datname = 'template0';
\q
EOF

#
# Be re-entrant against multiple invocations
#
# Remove the databases before the owning user; otherwise psql
# will complain of not being able to remove the user ..
#
sudo -u postgres dropdb msf_dev_db
sudo -u postgres dropdb msf_test_db
sudo -u postgres dropuser msfdev

sudo -u postgres psql -f /tmp/pg-utf8.sql &&
sudo -u postgres createuser msfdev -dRS &&
sudo -u postgres psql -c \
  "ALTER USER msfdev with ENCRYPTED PASSWORD '$DB_PASSWORD';" &&
sudo -u postgres createdb --owner msfdev msf_dev_db &&
sudo -u postgres createdb --owner msfdev msf_test_db &&
cat <<EOF> $HOME/.msf4/database.yml
# Development Database
development: &pgsql
  adapter: postgresql
  database: msf_dev_db
  username: msfdev
  password: $DB_PASSWORD
  host: localhost
  port: 5432
  pool: 5
  timeout: 5

# Production database -- same as dev
production: &production
  <<: *pgsql

# Test database -- not the same, since it gets dropped all the time
test:
  <<: *pgsql
  database: msf_test_db
EOF

sudo cp -vf $HOME/.msf4/database.yml /root/.msf4/

# Create the schema tables
rake db:migrate RAILS_ENV=test

./msfconsole -qx "db_status; exit"
