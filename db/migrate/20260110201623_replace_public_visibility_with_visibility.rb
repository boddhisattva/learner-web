class ReplacePublicVisibilityWithVisibility < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def up
    add_column :learnings, :visibility, :integer, null: false, default: 0

    safety_assured do
      add_check_constraint :learnings,
                           'visibility IN (0, 1, 2)',
                           name: 'learnings_visibility_check'
    end

    safety_assured do
      execute <<-SQL.squish
        UPDATE learnings
        SET visibility = CASE
          WHEN public_visibility = false THEN 0
          WHEN public_visibility = true THEN 1
        END
      SQL
    end

    add_index :learnings, %i[visibility organization_id],
              name: 'index_learnings_on_visibility_and_org_id', algorithm: :concurrently

    safety_assured { remove_column :learnings, :public_visibility }
  end

  def down
    add_column :learnings, :public_visibility, :boolean

    safety_assured do
      execute <<-SQL.squish
          UPDATE learnings
          SET public_visibility = CASE
            WHEN visibility = 0 THEN false
            ELSE true
          END
      SQL
    end

    remove_index :learnings, name: 'index_learnings_on_visibility_and_org_id'

    remove_check_constraint :learnings, name: 'learnings_visibility_check'

    remove_column :learnings, :visibility
  end
end
