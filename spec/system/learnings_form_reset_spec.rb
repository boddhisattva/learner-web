# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learning Form Reset Functionality', type: :system do
  let(:user) { create(:user, :with_organization_and_membership) }
  let(:organization) { user.personal_organization }

  before do
    sign_in user
  end

  describe 'canceling new learning form', :js do
    it 'clears form and scrolls back to New Learning link when user cancels' do
      # Setup: Visit learnings page and open new learning form
      visit learnings_path

      # Click "New Learning" link to open the inline form
      click_link 'New Learning'

      # Wait for form to appear inside the form container
      expect(page).to have_selector('#new_learning_form form', wait: 5)

      # Optionally fill in some data to make it realistic
      fill_in 'Lesson', with: 'Test Learning'

      # Action: Click "Cancel" button
      click_button 'Cancel'

      # Expected Outcome 1: Form disappears from the page
      expect(page).not_to have_selector('#new_learning_form form')

      # Expected Outcome 2: Form container is empty (no form fields visible)
      expect(page).not_to have_field('Lesson')

      # Expected Outcome 3: "New Learning" link is visible in viewport
      expect(page).to have_link('New Learning', visible: true)
    end
  end
end
