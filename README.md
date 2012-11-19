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
Restart the survey-web app.