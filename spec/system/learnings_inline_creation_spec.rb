# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Inline Learning Creation', type: :system do
  let(:user) { create(:user, :with_organization_and_membership) }
  let(:organization) { user.personal_organization }

  before do
    sign_in user
  end

  describe 'successful inline creation flow' do
    before do
      Prosopite.pause
      create_list(:learning, 2, creator: user, last_modifier: user, organization: organization)
      Prosopite.resume
      visit learnings_path
      page.current_window.resize_to(1200, 815)
    end

    it 'creates a learning inline without page navigation and updates the list', :js do
      expect(page).to have_text('(2 total)').and have_no_selector('#new_learning_form form')

      click_link 'New Learning'
      expect(page).to have_selector('#new_learning_form form')
      expect(current_path).to eq(learnings_path)

      submit_new_learning_form

      sleep 0.025 # Wait for Turbo Stream updates

      verify_learning_created_and_ui_updated
    end

    def submit_new_learning_form
      within('#new_learning_form') do
        fill_in 'Lesson', with: 'My First Inline Learning'
        fill_in 'Description', with: 'Created without leaving the page'
        click_button 'Create Learning'
      end
    end

    def verify_learning_created_and_ui_updated
      verify_learning_was_created
      verify_ui_was_updated
    end

    def verify_learning_was_created
      expect(Learning.count).to eq(3)
      new_learning = Learning.last
      expect(new_learning.lesson).to eq('My First Inline Learning')
      expect(new_learning.creator).to eq(user)
    end

    def verify_ui_was_updated
      expect(page).to have_text('(3 total)')
      expect(page).to have_content(I18n.t('learnings.create.success', lesson: 'My First Inline Learning'))
      expect(page).to have_content('My First Inline Learning')
      expect(page).not_to have_selector('#new_learning_form form')
    end
  end

  describe 'validation error handling' do
    it 'shows inline errors without page reload and preserves form state', :js do
      Prosopite.pause
      create_list(:learning, 2, creator: user, last_modifier: user, organization: organization)
      Prosopite.resume
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

  describe 'canceling new learning form' do
    it 'clears form and scrolls back to New Learning link when user cancels', :js do
      visit learnings_path

      click_link 'New Learning'

      expect(page).to have_selector('#new_learning_form form', wait: 5)

      expect(page).to have_content('Learning categories')

      fill_in 'Lesson', with: 'Test Learning'

      click_button 'Cancel'

      expect(page).not_to have_selector('#new_learning_form form')

      expect(page).not_to have_field('Lesson')

      expect(page).not_to have_content('Learning categories')
    end
  end
end
