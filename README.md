# HQ Trust Core API

## Setup

### Prerequisites
* A running Docker environment

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
