# Kid Friendly Videos

## DB setup

### Dev

```
CREATE DATABASE kid_friendly_videos_development;
CREATE USER kid_friendly_videos_development WITH PASSWORD 'password';
ALTER USER kid_friendly_videos_development WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE "kid_friendly_videos_development" to kid_friendly_videos_development;
```

### Test

```
CREATE DATABASE kid_friendly_videos_test;
CREATE USER kid_friendly_videos_test WITH PASSWORD 'password';
ALTER USER kid_friendly_videos_test WITH SUPERUSER;
GRANT ALL PRIVILEGES ON DATABASE "kid_friendly_videos_test" to kid_friendly_videos_test;
```

### db restarting

```
bundle exec rake db:drop RAILS_ENV=development
bundle exec rake db:create RAILS_ENV=development
bundle exec rake db:migrate RAILS_ENV=development
```

### YouTube Channels

mother_goose_club = Channel.create(yt_id: 'UCJkWoS4RsldA1coEIot5yDA', min_age: 0, max_age: 5)
sesame_street = Channel.create(yt_id: 'UCoookXUzPciGrEZEXmh4Jjg', min_age: 0, max_age: 5)
yo_gabba_gabba = Channel.create(yt_id: 'UCxezak0GpjlCenFGbJ2mpog', min_age: 0, max_age: 5)
houston_zoo = Channel.create(yt_id: 'UCqKNzUHmCrvZsFDzpAR3GjA', min_age: 6, max_age: 9)
science_bob = Channel.create(yt_id: 'UCUqbcRop12FjVcKjCgN46Gw', min_age: 10, max_age: 12)
the_brain_scoop = Channel.create(yt_id: 'UCkyfHZ6bY2TjqbJhiH8Y2QQ', min_age: 13, max_age: 100)
