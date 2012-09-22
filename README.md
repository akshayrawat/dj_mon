# DJ Mon [![Build Status](https://secure.travis-ci.org/akshayrawat/dj_mon.png?branch=master)](http://travis-ci.org/akshayrawat/dj_mon)

A Rails engine based frontend for Delayed Job. It also has an [iPhone app](http://itunes.apple.com/app/dj-mon/id552732872).

## Demo
* [A quick video tour](http://www.akshay.cc/dj_mon/)
* [Sandbox Demo URL](http://dj-mon-demo.herokuapp.com/)
* Username: `dj_mon`
* Password: `password`
* [Demo Source](https://github.com/akshayrawat/dj_mon_demo)

## Installation

Add this line to your application's Gemfile:

    gem 'dj_mon'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dj_mon

## Note

Supports `activerecord` and `mongoid`.

## Usage

If you are using Rails =< 3.1, or if `config.assets.initialize_on_precompile` is set to false, then add this to `config/environments/production.rb`.

    config.assets.precompile += %w( dj_mon.js dj_mon.css)

Mount it in `routes.rb`

    mount DjMon::Engine => 'dj_mon'

This uses http basic auth for authentication. Set the credentials in an initializer - `config/initializers/dj_mon.rb`

    YourApp::Application.config.dj_mon.username = "dj_mon"
    YourApp::Application.config.dj_mon.password = "password"
    
If the credentials are not set, then the username and password are assumed to be the above mentioned.

If you need to whitelist to a certain ip address, or subnet, add them in an array:

    YourApp::Application.config.dj_mon.whitelist = ["127.0."]

Now only requests starting with 127.0. will be allowed. The default is to allow anyone. 

Now visit `http://localhost:3000/dj_mon` and profit!

## iPhone App
* The iPhone app is written in RubyMotion. [Source](https://github.com/akshayrawat/dj_mon_iphone).
* [On App Store](http://itunes.apple.com/app/dj-mon/id552732872)

## Contributing

### Things to do
* Mostly in the iPhone app. Mentioned in the [README](https://github.com/akshayrawat/dj_mon_iphone).

### Running the test suite

To run the test suite, execute the following commands from the project
root:

    gem install bundler
    bundle install
    rake test:prepare
    rake

![Screenshot](https://github.com/akshayrawat/dj_mon_demo/raw/master/docs/screenshot.jpg)