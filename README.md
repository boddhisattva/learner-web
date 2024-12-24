# Learner

## About

Life is journey of constant learnings and this is an attempt to keep track of at least some of those learnings in an attempt to be a better version of oneself everyday

## Functionalities implemented thus far

The following **features** are available via both the **Web app & in Mobile**

* User sign up & sign in(Uses **Hotwire Stimulus** as needed)
  * As part of a user sign up, an organization is created based on user name & it is associated with an appropriate membership
* Update User profile details(Uses **Hotwire Turbo** as needed)
* Add ability to create a new learning
  * Sample Learning Categories can be added through `rake db:seed`
  * Additional learning categories can be currently added through `rails c` backend manually


## App Development Status - Paused for now


## Usage

### Dependencies

* This app uses Ruby 3.3.6 & Rails 8.0.1

### Basic App setup

#### Installing app dependencies

* Run `bundle install` from a project's root directory to install the related dependencies.

#### Setting up the Database schema
  - From the project root directory:
    - Create the Database Schema with: `rake db:create` and `rake db:migrate`

#### Setting up a test user
* In order to get started with using the app with an existing user, one could use the `rake db:seed`
* Additional learning categories can be currently added through `rails c` BE manually

#### Running the Rails app & ensuring it takes in the latest CSS & JS changes

* Start the rails app with: `bin/dev`

**Please note**: This command also bundles the latest CSS & JS code that comes along/regularly changes throughout the development lifecycle of an app

#### Running the tests

* One can run the tests from the project root directory with the command `rspec`


