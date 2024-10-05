# Learner

## About

Life is journey of constant learnings and this is an attempt to keep track of at least some of those learnings in an attempt to be a better version of oneself everyday

## App Development Status - In progress

## Usage

### Dependencies

* This app uses Ruby 3.3.5 & Rails 7.2.1

### Basic App setup

#### Installing app dependencies

* Run `bundle install` from a project's root directory to install the related dependencies.

#### Setting up the DB schema
From the project root directory:
* Create the Database Schema with: `rake db:create` and `rake db:migrate`

#### Setting up the DB seeds
* In order to get started with using the app create a new User with `rake db:seed` command

#### Running the Rails app & ensuring it takes in the latest CSS & JS changes

* Start the rails app with: `bin/dev`

**Please note**: This command also bundles the latest CSS & JS code that comes along/regularly changes
                 throughout the lifecycle of an app

#### User Sign Up & Sign In

* New User Sign up is available via: '/users/sign_up'; E.g: 'http://localhost:3000/users/sign_up'
* Existing User Login is available via: '/users/sign_in'; E.g: 'http://localhost:3000/users/sign_in'
