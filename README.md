# CodePraise

Web API for the CodePraise application

[ ![Codeship Status for soumyaray/code_praise](https://app.codeship.com/projects/b454db90-a9c0-0135-3b68-622b0705736a/status?branch=master)](https://app.codeship.com/projects/256400)
---

## Routes

Our API is rooted at `/api/v0.1/` and has the following subroutes:
- `GET repo` – Index of all repos stored
- `GET repo/ownername/reponame` - Fetch metadata of a previously stored repo
- `POST repo/ownername/reponame` - Load a repo from Github and store metadata in API

## Setup

To setup and test this API on your own machine:

```
$ git clone git@github.com:soumyaray/code_praise.git
$ cd code_praise
$ bundle install
$ bundle exec rake db:migrate
$ RACK_ENV=test bundle exec rake db:migrate
$ bundle exec rake spec
```

You may have to add your Github developer token to `config/secrets.yml` (see example in folder)
