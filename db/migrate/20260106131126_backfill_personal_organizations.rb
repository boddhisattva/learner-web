# frozen_string_literal: true

class BackfillPersonalOrganizations < ActiveRecord::Migration[8.1]
  # rubocop:disable Rails/SkipsModelValidations
  def up
    User.find_each do |user|
      organization = Organization.find_by(name: user.name)

      if organization
        organization.update_columns(owner_id: user.id)
        user.update_columns(personal_organization_id: organization.id)
      end
    end
  end

  def down
    Organization.update_all(owner_id: nil)
    User.update_all(personal_organization_id: nil)
  end
  # rubocop:enable Rails/SkipsModelValidations
end
