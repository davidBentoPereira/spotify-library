# Spotify Library - The custom interface to visualize it's followed artists

## Setup

1. Pull down the app from version control
2. Make sure you have Postgres running
3. `bin/setup`
4. Create the files :
   - `.env.development.local`
   - `.env.test.local`
5. Fill the env vars of these files with your Spotify's API Keys. You can create some [here](https://developer.spotify.com/documentation/web-api).  

## Running the App

1. `bin/run`

## Tests and CI

1. `bin/ci` contains all the tests and checks for the app
2. `tmp/test.log` will use the production logging format
   *not* the development one.

## Production

* All runtime configuration should be supplied in the UNIX environment
* Rails logging uses lograge. `bin/setup help` can tell you how to see this locally