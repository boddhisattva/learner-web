# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learning Deletion', type: :system do
  let(:user) { create(:user, :with_organization_and_membership) }
  let(:organization) { user.personal_organization }

  before do
    sign_in user
  end

  describe 'successful deletion flow' do
    it 'deletes a learning and removes it from the list with success message', :js do
      learnings = create_list(:learning, 2, creator: user, last_modifier: user, organization: organization)
      learning_to_delete = learnings.first

      visit learnings_path

      # Ensure desktop viewport (in case previous mobile tests changed it)
      page.current_window.resize_to(1200, 815)

      expect(page).to have_text('(2 total)', wait: 5)
      expect(page).to have_content(learning_to_delete.lesson)

      within("#learning_#{learning_to_delete.id}") do
        accept_confirm do
          find('a.button.is-danger[data-turbo-method="delete"]').click
        end
      end

      sleep 0.025 # Wait for Turbo Stream updates

      expect(Learning.count).to eq(1)
      expect(page).to have_text('(1 total)', wait: 5)
      expect(page).to have_content(I18n.t('learnings.destroy.success', lesson: learning_to_delete.lesson))
      expect(page).not_to have_selector("#learning_#{learning_to_delete.id}")
    end
  end
end
