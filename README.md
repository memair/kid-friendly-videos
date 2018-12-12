# README

## DB setup

### Dev

```
CREATE DATABASE autism_video_recommender_development;
CREATE USER autism_video_recommender_development WITH PASSWORD 'password';
ALTER USER autism_video_recommender_development WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE "autism_video_recommender_development" to autism_video_recommender_development;
```

### Test

```
CREATE DATABASE autism_video_recommender_test;
CREATE USER autism_video_recommender_test WITH PASSWORD 'password';
ALTER USER autism_video_recommender_test WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE "autism_video_recommender_test" to autism_video_recommender_test;
```

### db restarting

```
bundle exec rake db:drop RAILS_ENV=development
bundle exec rake db:create RAILS_ENV=development
bundle exec rake db:migrate RAILS_ENV=development
```