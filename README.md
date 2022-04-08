# Hextile

This is an application I created for background live journaling, tracking, and logging my Pacific Crest Trail thru hike.
Much of it is custom built for my needs, but I took care to make it as extendable and customizable as possible. Anyone
can fork and host it for themself by setting a few environment variables. Feel free to pr any efforts you make to
improve the project.

#### Stack

- Ruby on Rails
- Turbo and Stimulus.js for client side reactivity.
- TailwindCSS
- Postgresql
- Redis for caching

## Developement

1. Fork it
2. Install gems `bundle install`
3. Create Database `rails db:create && rails db:migrate`
4. Start local server `.bin/dev`
5. Configure Data sources

## Data Sources

**MapTiler**
For displaying tiles on the map.

1. Get a [MapTiler](https://cloud.maptiler.com/account/keys/) api key.
2. Set `MAPTILER_KEY` to that key in [map_controller.js](app/javascript/controllers/map_controller.js). You can also
   easily swap MapTiler for a different tile provider in the same file.

**Google Photos**
Display your photos.

1. Create a Google Developer account and [generate a key](https://console.cloud.google.com/apis/credentials) with read
   access to your albums.
2. Add the required Authorized redirect URI to that key: `YOUR_DOMAIN/admins/auth/google_oauth2/callback` (
   ie. `http://localhost:3000/admins/auth/google_oauth2/callback`)
3. Set the the `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` env variables (ie. in application.yml locally).
4. Create an album in your Google Photos Account and set the `MEDIA_ALBUM` env variable to that albums title.
5. Set the `ADMIN_EMAIL` env variable to the email account associated with your google photos.

**Garmin**

1. Create a public map on [explore.garmin.com](explore.garmin.com). I'd suggest filtering whats on the map to only
   include the waypoints from your time on trail. Otherwise modify the method `nearest_point` in [Map](app/models/map.rb) to only search within a
   fixed mileage to keep the maps accurate.
2. Set `GARMIN_USERNAME` env variable to the username chosen there.
3. Get and set a `MAPQUEST_KEY` env variable to add detailed information to waypoints.

**Posts**
I implemented a somewhat complex but now automatic system of fetching content from another GitHub repo synced with my notes app on phone and computer.
You can see more about how to set that up for yourself over at the [Github action](https://github.com/4till2/generate-content-map-action) I wrote for this.
Once you get that configured come back and...
1. Set the `POST_CONTENT_URL` env variable to the url of that actions generated results. (See [application.sample.yml](config/application.sample.yml) for an example.)
2. Set the `POST_IMAGES_URL` env variable to the base url of any attachments you may upload in that repository.

## Deploy
I deploy with [Fly.io](fly.io) since it was really easy to configure, connect, and automate.
Follow their docs on Deploying a Rails app and setting up a Redis server for a through guide.
The only down side is the lack of an online interface for setting environment variables which means no modifying them on trail.

## Contributing

1. Fork it
2. Create your feature branch `git checkout -b my-new-feature`
3. Commit your changes `git commit -am 'Add some feature'`
4. Push to the branch `git push origin my-new-feature`
5. Create new Pull Request
