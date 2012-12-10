survey-web [![Build Status](https://secure.travis-ci.org/c42/survey-web.png)](http://travis-ci.org/c42/survey-web)
==========

A web application to create and conduct surveys

Terminology
===========

- Survey   - Collection of Questions
- Question - A specificaton for a piece of info that the survey designer wants to collect.
- Answer   - A piece of information for a question
- Response - The set of a user's answers for a particular survey

Setup
=====

Database
--------

- You need to set up a local database. Any of the databases [supported by Rails](http://api.rubyonrails.org/classes/ActiveRecord/Migration.html#label-Database+support) will work, but [PostgreSQL](http://www.postgresql.org/) is recommended.
- Some tutorials are [here](https://help.ubuntu.com/community/PostgreSQL) and [here](http://wiki.postgresql.org/wiki/Detailed_installation_guides). If you're on a mac, use Heroku's [Postgres.app](http://postgresapp.com/)
- Make a copy of the `database.yml.sample` provided (in the `config` directory); name it `database.yml`
- Fill in the details for your database.

For example, the `database.yml` will look something like this if you're using Postgres.app:

```YAML
development:
  adapter: postgresql
  encoding: utf8
  database: survey_web_dev
  pool: 5
  username: 
  password: 
  host: localhost

test:
  adapter: postgresql
  encoding: utf8
  database: survey_web_test
  pool: 5
  username: 
  password:
  host: localhost

production:
  adapter: postgresql
  encoding: utf8
  database: survey_web_prod 
  pool: 5
  username:
  password:
```

- Navigate to the survey-web directory from a terminal.
- Type `rails server`
- If the server starts up without complaining, your database is set up correctly.

Gems
----

- To install all the libraries required by this application, navigate to the survey-web directory from a terminal.
- Type `gem install bundler` and then `bundle install`

OAuth Provider
----------

This app works with an OAuth Provider that you'll need to set up as well.
You can clone it at http://github.com/c42/user-owner

- Login as admin in the user-owner app
- Click on ***Add a new application***
- The redirect uri would be `http://SURVEY_WEB_URL/auth/user_owner/callback` (`SURVEY_WEB_URL` is the URL where the survey-web app is hosted)
- You will then have the Application ID and the Secret.
- Create a config/application.yml file in this (survey-web) app

- Add the following to it:

```yaml
OAUTH_ID: # Application ID of the OAuth provider.
OAUTH_SECRET: # Secret of the OAuth provider.
OAUTH_SERVER_URL: # URL where the OAuth Provider instance is hosted.
```

Finally...
-------
Start the survey-web app by typing `rails server` from the console.