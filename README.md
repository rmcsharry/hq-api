# HQ Trust Core API

## Setup

### Prerequisites
* A running Docker environment

#### Certificates
The HQ Trust [Outlook Add-in](https://github.com/HQTrust/hq-outlook-addin) requires the API to be exposed via SSL also when running in development. That is because the add-in runs as an `iframe` in context of the [Outlook Web App](https://outlook.live.com) which is of course enforcing https.

You can use mkcert in order to create such certificate on your system:

  1. Use mkcert:
    1. [Install mkcert](https://github.com/FiloSottile/mkcert#installation) on your system
    1. Run `CAROOT="$(pwd)/cert" mkcert -install` in this projects root to create and trust a ca certificate
    1. Run `cd cert`
    1. Run `mkcert localhost` in this projects root create a certificate for localhost, signed by above ca certificate

### Install
After cloning the project locally, run
```
docker-compose build
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

To debug, add `binding.pry` to the code to add a breakpoint at that line.

## Stack

### API

#### Specification
The API follows the [JSON API](http://jsonapi.org/) specification. It is implemented using [JSONAPI::Resources](http://jsonapi-resources.com/). An example project for JSONAPI::Resource can be found [here](https://github.com/cerebris/peeps).

#### Authentication


#### Authorization
Authorization is handled by [JSONAPI::Authorization](https://github.com/venuu/jsonapi-authorization).
