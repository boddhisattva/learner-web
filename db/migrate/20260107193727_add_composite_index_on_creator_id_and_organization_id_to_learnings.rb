# frozen_string_literal: true

class AddCompositeIndexOnCreatorIdAndOrganizationIdToLearnings < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    # Composite index to optimize queries filtering by creator_id and organization_id
    # Used in LearningsController#current_user_learnings:
    # current_user.learnings.where(organization_id: current_organization.id)
    add_index :learnings, %i[creator_id organization_id],
              algorithm: :concurrently,
              name: 'index_learnings_on_creator_id_and_organization_id'
  end

  def down
    remove_index :learnings, name: 'index_learnings_on_creator_id_and_organization_id'
  end
end

