# Learner

## About

Life is journey of constant learnings and this is an attempt to keep track of at least some of those learnings in an attempt to be a better version of oneself everyday

## Functionalities implemented thus far

The following **features** are available via both the **Web app & in Mobile**

* User sign up & sign in(Uses **Hotwire Stimulus** as needed)
* Update User profile details(Uses **Hotwire Turbo** as needed)

## App Development Status - In progress

Demo of work done so far is deployed at https://learner-web.onrender.com/

## Usage

### Dependencies

* This app uses Ruby 3.3.5 & Rails 7.2.1

### Basic App setup

#### Installing app dependencies

* Run `bundle install` from a project's root directory to install the related dependencies.

#### Setting up the Database schema
  - From the project root directory:
    - Create the Database Schema with: `rake db:create` and `rake db:migrate`

#### Setting up a test user
* In order to get started with using the app with an existing user, one could use the `rake db:seed` command

#### Running the Rails app & ensuring it takes in the latest CSS & JS changes

* Start the rails app with: `bin/dev`

**Please note**: This command also bundles the latest CSS & JS code that comes along/regularly changes throughout the development lifecycle of an app

#### Running the tests

* One can run the tests from the project root directory with the command `rspec`


