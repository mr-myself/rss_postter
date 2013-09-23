RSS Postter
===========

If you register RSS feed URL, this app post to twitter account as mentions automatically.

------

## About development environment
 * Ruby 2.0.0 (maybe it works 1.9* also)
 * Sinatra (Web Application Framework for Ruby)
 * Slim (template engine for Ruby)
 * Backbone.js (Web Application Framework for JavaScript)
 * SQLite3 (of course, you can change this easilly)


### First to start this, what you should do are... 

 * git clone
 * bundle install 
 * create database  
 * register this app on twitter developer site
 * ready config.yml

This app can use rack, so just type
```console
$ bundle exec rackup
```

### Create Database
Make 'rss_post.db' file on the app root, and type the command.

$ sqlite3 rss_post.db

```sqlite
CREATE TABLE rsses(id integer primary key, title varchar, url varchar);
CREATE TABLE user_rss_maps(id integer primary key, user_id integer, rss_id integer);
CREATE TABLE users(id integer primary key, account varchar);
```

### Register this app
https://dev.twitter.com/apps/new


### Ready config.yml
After you register this app, you'll have some keys.  
Please write down them in config.yml, and put it on the app root, such this.  
```yaml
twitter:  
  key:
  secret:
  oauth_token:
  oauth_token_secret:
```
