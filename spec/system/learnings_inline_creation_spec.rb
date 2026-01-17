# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Inline Learning Creation', type: :system do
  let(:user) { create(:user, :with_organization_and_membership) }
  let(:organization) { user.personal_organization }

  before do
    sign_in user
  end

  describe 'successful inline creation flow' do
    it 'creates a learning inline without page navigation and updates the list', :js do
      # Setup: Start with 2 existing learnings
      create_list(:learning, 2, creator: user, last_modifier: user, organization: organization)
      visit learnings_path

      # Ensure desktop viewport (in case previous mobile tests changed it)
      page.current_window.resize_to(1200, 815)

      expect(page).to have_text('(2 total)')
      expect(page).not_to have_selector('#new_learning_form form')

      click_link 'New Learning'

      expect(page).to have_selector('#new_learning_form form')
      expect(current_path).to eq(learnings_path) # No page navigation

      within('#new_learning_form') do
        fill_in 'Lesson', with: 'My First Inline Learning'
        fill_in 'Description', with: 'Created without leaving the page'
        click_button 'Create Learning'
      end

      sleep 0.025 # Wait for Turbo Stream updates

      expect(Learning.count).to eq(3)
      expect(Learning.last.lesson).to eq('My First Inline Learning')
      expect(Learning.last.creator).to eq(user)

      expect(page).to have_text('(3 total)')

      expect(page).to have_content(I18n.t('learnings.create.success', lesson: 'My First Inline Learning'))

      expect(page).to have_content('My First Inline Learning')

      expect(page).not_to have_selector('#new_learning_form form')
    end
  end

  describe 'validation error handling' do
    it 'shows inline errors without page reload and preserves form state', :js do
      create_list(:learning, 2, creator: user, last_modifier: user, organization: organization)
      visit learnings_path

      page.current_window.resize_to(1200, 815)

      expect(page).to have_text('(2 total)')

      click_link 'New Learning'
      expect(page).to have_selector('#new_learning_form form')

      within('#new_learning_form') do
        fill_in 'Lesson', with: ''
        fill_in 'Description', with: 'Some description'
        click_button 'Create Learning'
      end

      expect(Learning.count).to eq(2)

      expect(page).to have_selector('#new_learning_form form')

      expect(page).to have_content("Lesson can't be blank")

      expect(page).to have_text('(2 total)')

      expect(page).not_to have_content('is created successfully')

      expect(page).to have_field('Description', with: 'Some description')

      expect(current_path).to eq(learnings_path)
    end
  end
end
