# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learnings Inline Editing', type: :system do
  include ActionView::RecordIdentifier

  let(:user) { create(:user) }
  let(:organization) { user.personal_organization }
  let(:learning) do
    create(:learning,
           creator: user,
           last_modifier: user,
           organization: organization,
           lesson: 'Original Lesson',
           description: 'Original Description')
  end

  before do
    sign_in user
  end

  describe 'successful inline editing flow' do
    it 'updates learning inline and replaces form with updated display view', :js do
      learning
      visit learnings_path

      # Ensure desktop viewport (in case previous mobile tests changed it)
      page.current_window.resize_to(1200, 815)
      # sleep 0.5 # Allow page to stabilize after resize

      expect(page).to have_content('Original Lesson')
      expect(page).not_to have_field('Lesson', with: 'Original Lesson')

      # Action: Click edit button (yellow button)
      within("turbo-frame##{dom_id(learning)}") do
        find('a.button.is-warning').click
      end

      # Outcome: Form loads inline
      expect(page).to have_field('Lesson', with: 'Original Lesson', wait: 10)
      expect(page).to have_field('Description', with: 'Original Description')
      expect(page).to have_button('Update Learning')

      fill_in 'Lesson', with: 'Updated Lesson Name'
      fill_in 'Description', with: 'Updated Description Text'
      click_button 'Update Learning'

      expect(page).not_to have_field('Lesson')
      expect(page).not_to have_button('Update Learning')

      expect(page).to have_content('Updated Lesson Name')
      expect(page).not_to have_content('Original Lesson')

      learning.reload
      expect(learning.lesson).to eq('Updated Lesson Name')
      expect(learning.description).to eq('Updated Description Text')
    end
  end

  describe 'validation error handling' do
    it 'displays validation errors inline without leaving edit mode', :js do
      learning
      visit learnings_path

      # Ensure desktop viewport (in case previous mobile tests changed it)
      page.current_window.resize_to(1200, 815)
      # sleep 0.5 # Allow page to stabilize after resize

      # Action: Click edit button
      within("turbo-frame##{dom_id(learning)}") do
        find('a.button.is-warning').click
      end

      # Outcome: Form loads
      expect(page).to have_field('Lesson', with: 'Original Lesson', wait: 10)

      fill_in 'Lesson', with: ''
      fill_in 'Description', with: 'This description should be preserved'
      click_button 'Update Learning'

      # Outcome: Still in edit mode
      expect(page).to have_field('Lesson')
      expect(page).to have_button('Update Learning')

      expect(page).to have_content("Lesson can't be blank")

      expect(page).to have_field('Description', with: 'This description should be preserved')

      learning.reload
      expect(learning.lesson).to eq('Original Lesson')
      expect(learning.lesson).not_to eq('')
    end
  end
end
