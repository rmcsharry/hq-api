# HQ Trust Core API

## Build status

**master**: [![Codeship Status for HQTrust/hqtrust-core-api](https://app.codeship.com/projects/c2459e30-e383-0135-bca6-623ae4419be6/status?branch=master)](https://app.codeship.com/projects/268637)

**dev**: [![Codeship Status for HQTrust/hqtrust-core-api](https://app.codeship.com/projects/c2459e30-e383-0135-bca6-623ae4419be6/status?branch=dev)](https://app.codeship.com/projects/268637)

## Setup

### Prerequisites
* A running Docker environment

#### Certificates
*The following step is needed only if you plan to develop against the HQ Trust Outlook Add-In.*

The HQ Trust [Outlook Add-in](https://github.com/HQTrust/hq-outlook-addin) requires the API to be exposed via SSL also when running in development. That is because the add-in runs as an `iframe` in context of the [Outlook Web App](https://outlook.live.com) which is of course enforcing https.

You can use mkcert in order to create such certificate on your system:

  1. Use mkcert:
    1. [Install mkcert](https://github.com/FiloSottile/mkcert#installation) on your system
    1. Run `CAROOT="$(pwd)/cert" mkcert -install` in this projects root to create and trust a ca certificate
    1. Run `cd cert`
    1. Run `mkcert localhost` in this projects root create a certificate for localhost, signed by above ca certificate

### Install
After cloning the project locally, install a Docker VM and docker-compose for your OS.

Then, run
```
docker-compose build
docker-compose run api rake db:create db:migrate db:populate
```

### Develop
To run the server locally, run
```
docker-compose up
```

In case the database needs to be migrated, run
```
docker-compose run api rake db:migrate
```

To reset the database, run
```
docker-compose run api rake db:drop db:create db:migrate
```

To populate the database, run
```
docker-compose run api rake db:populate
```

This command can also be chained to reset and re-populate the database:
```
docker-compose run api rake db:drop db:create db:migrate db:populate
```

### Debugging

To debug, add `binding.pry` to the code to add a breakpoint at that line.
Then, start the project with the following command (instead of `docker-compose up`) so that it stops interatactively at your breakpoint:
```
bin/interactive-puma
```

## Stack

### API

#### Specification
The API follows the [JSON API](http://jsonapi.org/) specification. It is implemented using [JSONAPI::Resources](http://jsonapi-resources.com/). An example project for JSONAPI::Resource can be found [here](https://github.com/cerebris/peeps).

#### Authentication


#### Authorization
Authorization is handled by [JSONAPI::Authorization](https://github.com/venuu/jsonapi-authorization).

## Wiki

Find additional information about this project in our [Wiki](https://github.com/HQTrust/hqtrust-core-api/wiki).
