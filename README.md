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

- Login as super_admin in the user-owner app
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


Troubleshooting
=======
Please check the [Troubleshooting](https://github.com/c42/survey-web/wiki/Troubleshooting) section of the wiki, or create an [issue](https://github.com/c42/survey-web/issues) if you need any help.

Contributing
=======
- We use [Pivotal Tracker](https://www.pivotaltracker.com/projects/602833) to manage our projects.
You can have a look at the bugs and features that you could work on.
- If you need any help, mail us at `survey@c42.in`.


Other Notes
========

Setup `delayed_job` to Upload Photos to Amazon S3
-----------

- If delayed_job workers aren't running, photos will stay on the app server, and will not be migrated to S3.
- [Setup](https://github.com/jnicklas/carrierwave#using-amazon-s3) `Carrierwave` with your Amazon S3 credentials.
- Start `delayed_job` workers using `script/delayed_job`. Look [here](https://github.com/collectiveidea/delayed_job#running-jobs) for documentation.
- If you're deploying to EngineYard, a deploy hook is provided in `deploy/after_restart.rb`.

Setup organization deletion
-----------

- Organizations can be (soft) deleted on user-owner
- Running `rake db:remove_deleted_organizations_data` on survey-web will delete all data (surveys, questions, responses etc.) belonging to any soft-deleted organisations
- Run it in a cron job so that this cleanup doesn't have to happen manually (although it is delayed)

Setup Logentries on Engineyard
-----------

To include unicorn and nginx config files as well, follow the instructions provided by EngineYard to upload a custom recipe, but replace configure.rb with the contents of [this gist](https://gist.github.com/timothyandrew/79de202f486c26eb40e0).
