survey-web [![Build Status](https://secure.travis-ci.org/c42/survey-web.png)](http://travis-ci.org/c42/survey-web)
==========

A web application to create and conduct surveys

Terminology
===========

Survey   - Collection of Questions
Question - A specificaton for a piece of info that the survey designer wants to collect.
Answer   - A piece of information for a question
Response - The set of a user's answers for a particular survey

OAuth
=====

To use this app with an instance of the [user-owner](http://user-owner-staging.herokuapp.com/) OAuth2 provider, add a file `config/application.yml` with the following options:

```yaml
OAUTH_ID: # Application ID of the provider.
OAUTH_SECRET: # Secret of the provider.
OAUTH_SERVER_URL: # URL where the user-owner instance is hosted.
```

You can register this app with the OAuth provider at `$OAUTH_SERVER_URL/oauth/applications`