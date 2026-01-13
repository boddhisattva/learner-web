# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user = User.find_or_create_by!(email: 'abhimanyud@test.com') do |u|
  u.first_name = 'Abhimanyu'
  u.last_name = 'Dharmveer'
  u.password = 'passwd123'
  u.password_confirmation = 'passwd123' # needs to be at least 8 characters
end

chris_user = User.find_or_create_by!(email: 'chrish@test.com') do |u|
  u.first_name = 'Chris'
  u.last_name = 'Hemsworth'
  u.password = 'tester1234'
  u.password_confirmation = 'tester1234'
end

personal_organization = Organization.find_or_create_by!(name: user.name) do |org|
  org.owner = user
end

user.update!(personal_organization: personal_organization) unless user.personal_organization_id

Membership.find_or_create_by!(member: user, organization: personal_organization)

earth_as_organization = Organization.find_or_create_by!(name: 'Earth') do |org|
  org.owner = user
end

earth_as_organization = Organization.find_or_create_by!(name: 'Earth') do |org|
  org.owner = chris_user
end

Membership.find_or_create_by!(member: user, organization: earth_as_organization)
Membership.find_or_create_by!(member: chris_user, organization: earth_as_organization)

LearningCategory.find_or_create_by!(name: 'Learnings for Life', organization: personal_organization) do |cat|
  cat.creator_id = user.id
  cat.last_modifier_id = user.id
end

LearningCategory.find_or_create_by!(name: 'Learnings for Life', organization: earth_as_organization) do |cat|
  cat.creator_id = chris_user.id
  cat.last_modifier_id = chris_user.id
end

discipline_category = LearningCategory.find_or_create_by!(name: 'Discipline', organization: personal_organization) do |cat|
  cat.creator_id = user.id
  cat.last_modifier_id = user.id
end

Learning.find_or_create_by!(lesson: 'Karm kar Phal ki chinta na kar',
                            creator: user,
                            organization: personal_organization) do |learning|
  learning.category_ids = [discipline_category.id]
  learning.last_modifier_id = user.id
end

100.times do |n|
  lesson_name = "What is delayed is not denied #{n + 1}"
  learning = Learning.find_or_create_by!(lesson: lesson_name,
                                         creator: user,
                                         organization: personal_organization) do |l|
    l.category_ids = [discipline_category.id]
    l.last_modifier_id = user.id
  end
  # Update lesson and description to match actual ID after creation/finding
  learning.update!(lesson: "What is delayed is not denied #{learning.id}",
                   description: "Description for learning #{learning.id}",
                   last_modifier_id: user.id)
end
