# frozen_string_literal: true

class AddCompositeIndexOnCreatorIdAndOrganizationIdToLearnings < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_index :learnings, %i[creator_id organization_id],
              algorithm: :concurrently,
              name: 'index_learnings_on_creator_id_and_organization_id'
  end

  def down
    remove_index :learnings, name: 'index_learnings_on_creator_id_and_organization_id'
  end
end
