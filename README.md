# AwesomeNoteA

## Table of Contents

- [Requirements](##requirements)
- [Initialization](##initialization)
- [Setup](##setup)
- [Deployment](##deployment)
- [Supplement](##supplement)

## Requirements

- Docker 19.x

If you run the project locally, the followings are required.

- Ruby 3.0.0
- Bundler 2.1.x
- Node.js 14.15.1
- Yarn 1.22.x
- Postgres 14.x

## Setup

Setup procedure of development environment.

Run `cp .env.example .env` and open `.env` file to edit environment variables.

### Docker environment

Build docker containers

```bash
docker-compose build
```

Setup database Development

```bash
docker-compose run web bundle exec rake db:create db:migrate db:seed
```

After running seed, there should be a doorkeeper application record in your database. In your rails console, run the following command:

```bash
Doorkeeper::Application.last
```

Copy uid and secret and put them in NextJS project's .env file under corresponding env variables: NEXT_APP_CLIENT_ID and NEXT_APP_CLIENT_SECRET

Setup database Test

```bash
docker-compose run web bundle exec rake db:create db:migrate db:seed RAILS_ENV=test
```

Rswag

```bash
docker-compose run web  bundle exec rake rswag:specs:swaggerize
```

Start the app

```bash
docker-compose up
```

### Local environment without Docker

If you want to use Rails without Docker, then follow below steps

Install dependencies

```bash
bundle install
```

Start postgres and setup database

```bash
bin/rake db:create db:migrate db:seed
```

Start the app

```bash
## API server
bin/rails s
```

Start console

```bash
bin/rails c
```

## Mail server in development environment

If you install and run rails server on your local machine, email will be open immediately on your browser when an email is sent by rails. If you're using docker, please go to mailbox at `http://localhost:1080`

## Deployment

Once you created the staging and production environments in Jitera's DevOps menu, you can deploy to staging by pushing a new commit to `develop` branch, and to production by pushing a new commit to `master` branch.

## DB Dump from Server to local

Please read [notion](https://www.notion.so/iruuzainc/Production-Staging-Dump-from-ECS-containers-6affe4fddec541ee93aba797aab084ed) for DB dump steps

## Supplement

This project was generated by jitera automation, run by Jitera.
