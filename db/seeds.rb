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

personal_organization = Organization.find_or_create_by!(name: user.name) do |org|
  org.owner = user
end

user.update!(personal_organization: personal_organization) unless user.personal_organization_id

Membership.find_or_create_by!(member: user, organization: personal_organization)

earth_as_organization = Organization.find_or_create_by!(name: 'Earth') do |org|
  org.owner = user
end

Membership.find_or_create_by!(member: user, organization: earth_as_organization)

LearningCategory.find_or_create_by!(name: 'Learnings for Life', organization: personal_organization) do |cat|
  cat.creator_id = user.id
  cat.last_modifier_id = user.id
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
  Learning.find_or_create_by!(lesson: lesson_name,
                              creator: user,
                              organization: personal_organization) do |learning|
    learning.description = "Description for learning #{n + 1}"
    learning.category_ids = [discipline_category.id]
    learning.last_modifier_id = user.id
  end
end
