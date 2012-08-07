# DJ Mon

A Rails engine based frontend for Delayed Job.

## Installation

Add this line to your application's Gemfile:

    gem 'dj_mon'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dj_mon

## Note

Supports only `activerecord` and `mongoid` for now.

## Usage

If you are using Rails =< 3.1, or if `config.assets.initialize_on_precompile` is set to false, then add this to `config/environments/production.rb`.

    config.assets.precompile += %w( dj_mon.js dj_mon.css)

Mount it in `routes.rb`

    mount DjMon::Engine => 'dj_mon'

This uses http basic auth for authentication. Set the credentials in an initializer - `config/initializers/dj_mon.rb`

    YourApp::Application.config.dj_mon.username = "dj_mon"
    YourApp::Application.config.dj_mon.password = "password"
    
If the credentials are not set, then the username and password are assumed to be the above mentioned.

Now visit `http://localhost:3000/dj_mon` and profit!
  

## Demo

* [Demo URL](http://dj-mon-demo.herokuapp.com/)
* Username: `dj_mon`
* Password: `password`
* [Demo Source](https://github.com/akshayrawat/dj_mon_demo)

![Screenshot](https://github.com/akshayrawat/dj_mon_demo/raw/master/docs/screenshot.jpg)
