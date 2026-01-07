# Learner

## About

Life is journey of constant learnings and this is an attempt to keep track of at least some of those learnings in an attempt to be a better version of oneself everyday

## Functionalities implemented thus far

The following **features** are available via both the **Web app & in Mobile**

* User sign up & sign in(Uses **Hotwire Stimulus** as needed)
  * As part of a user sign up, an organization is created based on user name & it is associated with an appropriate membership
* Update User profile details(Uses **Hotwire Turbo** as needed)
* Add ability to create a new learning
  * Sample Learnings & Learning Categories can be added through `rake db:seed`
  * Additional learning categories can be currently added through `rails c` backend manually
* **Learning Search** implemented using **Stimulus** and related features like Stimulus Target
* **Infinite scroll** implementation using **Turbo Frames**
* **Inline functionalities** for - Learning creation, update using **Turbo Streams**
  - Functionalities like Update make use of features like **Morphing** that allows one to preserve scroll position and provides a better UX in general(especially in Mobile)
* Learning deletion also implemented with **Turbo Streams** to give a more intuitive user experience
* **Floating flash notifications** implemented for operations like learning create, update & delete to give a much better User experience.

## App related screenshots

<details>
  <summary>View App related screenshots</summary>

1. Create New Inline Learning
  ![Alt text](https://imgur.com/Z8meaL7.png "Create New Inline Learning")

2. Learnings Index
  ![Alt text](https://imgur.com/eXSWUzi.png "Learnings Index")

3.Learnings Show
  ![Alt text](https://imgur.com/rkPZ6u9.png "Learnings Show")

4. Update Learnings Inline & confirm updates with Floating Notifcations
  ![Alt text](https://imgur.com/BaV3MVw.png "Learnings with Floating Notifcations")

5. Learnings Rendered in Mobile View

  ![Alt text](https://imgur.com/y38TMWn.png "Mobile Index")

6. Search learnings via Mobile view

  ![Alt text](https://imgur.com/BYneXRl.png "Mobile Search")

7. Learning related Floating Notifications in Mobile view

  ![Alt text](https://imgur.com/kQ7JD2W.png "Mobile Search")



</details>

## Features that are currently a Work in Progress(WIP)
* Implementing Learning Categories, Memberships & Organisations fully pertaining to a user's learning is a current WIP

## Usage

### Dependencies

* This app uses Ruby 3.3.6 & Rails 8.1.1

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


#### Areas of Improvement
* Replace acts_as_paranoid with discard gem as that's more flexible &
  provides better future readynesss in terms of long term extendability(to allow support of more features etc.,) and maintainability
* `load_learning_categories`(used in `LearningsController`) currently loads 100 learning categories. We can improve this further by providing UI options in appropriate parts of the app to filter and search learnings by other learning categories
