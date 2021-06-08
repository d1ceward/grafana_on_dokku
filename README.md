![](.github/images/repo_header.png)

[![Grafana](https://img.shields.io/badge/Grafana-8.0.0-blue.svg)](https://github.com/grafana/grafana/releases/tag/v8.0.0)
[![Dokku](https://img.shields.io/badge/Dokku-Repo-blue.svg)](https://github.com/dokku/dokku)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/D1ceWard/grafana_on_dokku/graphs/commit-activity)

# Run Grafana on Dokku

## Perquisites

### What is Grafana?

[Grafana](https://grafana.com/) is an open source, feature rich metrics dashboard and graph editor for
Graphite, Elasticsearch, OpenTSDB, Prometheus and InfluxDB.

### What is Dokku?

[Dokku](http://dokku.viewdocs.io/dokku/) is the smallest PaaS implementation
you've ever seen - _Docker powered mini-Heroku_.

### Requirements

* A working [Dokku host](http://dokku.viewdocs.io/dokku/getting-started/installation/)
* [PostgreSQL](https://github.com/dokku/dokku-postgres) plugin for Dokku
* [Letsencrypt](https://github.com/dokku/dokku-letsencrypt) plugin for SSL (optionnal)

# Setup

**Note:** We are going to use the domain `grafana.example.com` for demonstration purposes. Make sure to
replace it to your domain name.

## App and plugins

### Create the app

Log onto your Dokku Host to create the Grafana app:

```bash
dokku apps:create grafana
```

### Add plugins
Install, create and link PostgreSQL plugin:

```bash
# Install postgres plugin on Dokku
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
```

```bash
# Create running plugin
dokku postgres:create grafana
```

```bash
# Link plugin to the main app
dokku postgres:link grafana grafana
```

## Configuration

### Add GF_DATABASE_URL and GF_SERVER_HTTP_PORT to environement variables

```bash
# Show all enironement variables to copy content of DATABASE_URL variable
dokku config grafana
```

```bash
# Set GF_DATABASE_URL
dokku config:set grafana GF_DATABASE_URL='previously_copied_database_url'
```

```bash
# Set port to 5000
dokku config:set grafana GF_SERVER_HTTP_PORT=5000
```

### Setting secret key

```bash
dokku config:set grafana GF_SECURITY_SECRET_KEY=$(echo `openssl rand -base64 45` | tr -d \=+ | cut -c 1-32)
```

## Domain setup

To get the routing working, we need to apply a few settings. First we set the domain.

```bash
dokku domains:set grafana grafana.example.com
```

## Push Grafana to Dokku

### Grabbing the repository

First clone this repository onto your machine.

#### Via SSH

```bash
git clone git@github.com:D1ceWard/grafana_on_dokku.git
```

#### Via HTTPS

```bash
git clone https://github.com/D1ceWard/grafana_on_dokku.git
```

### Set up git remote

Now you need to set up your Dokku server as a remote.

```bash
git remote add dokku dokku@example.com:grafana
```

### Push Grafana

Now we can push Grafana to Dokku (_before_ moving on to the [next part](#domain-and-ssl-certificate)).

```bash
git push dokku master
```

## SSL certificate

Last but not least, we can go an grab the SSL certificate from [Let's Encrypt](https://letsencrypt.org/).

```bash
# Install letsencrypt plugin
dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git

# Set certificate contact email
dokku config:set --no-restart grafana DOKKU_LETSENCRYPT_EMAIL=you@example.com

# Generate certificate
dokku letsencrypt grafana
```

In case of an error `Challenge validation has failed`, please check your proxy settings:

```bash
dokku proxy:report                          # you should see http:80:5000
dokku proxy:ports-add grafana http:80:5000  # otherwise, add the proxy to the port
```

## Wrapping up

Your Grafana instance should now be available on [https://grafana.example.com](https://grafana.example.com).

To add Grafana plugins, simply set the environment variable named `GF_INSTALL_PLUGINS`:

```
dokku config:set grafana GF_INSTALL_PLUGINS=grafana-piechart-panel,grafana-github-datasource
```
