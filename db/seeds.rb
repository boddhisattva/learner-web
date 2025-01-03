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

user = User.create!(first_name: 'Abhimanyu',
                    last_name: 'Dharmveer',
                    email: 'abhimanyud@test.com',
                    password: 'passwd123',
                    password_confirmation: 'passwd123') # needs to be at least 8 characters

organization = Organization.find_or_create_by(name: user.name)

Membership.create(member_id: user.id, organization_id: organization.id)

earth_as_organization = Organization.create(name: 'Earth') # This is a worldwide public organization

Membership.create(member_id: user.id, organization_id: earth_as_organization.id)

LearningCategory.create(name: 'Learnings for Life', creator_id: User.first.id,
                        last_modifier_id: User.first.id)

learning_category = LearningCategory.create(name: 'Discipline', creator_id: User.first.id,
                                            last_modifier_id: User.first.id)

Learning.create(lesson: 'Karm kar Phal ki chinta na kar', learning_category_ids: [learning_category.id],
                creator_id: User.first.id, last_modifier_id: User.first.id, organization_id: organization.id)
