# frozen_string_literal: true

require 'rails_helper'

describe 'Root routing behavior', type: :system do
  let(:user) { create(:user) }
  let(:organization) { create(:organization, owner: user) }
  let(:membership) { create(:membership, member: user, organization: organization) }

  before do
    membership
  end

  describe 'authenticated user' do
    before do
      sign_in user
    end

    it 'does not show "You are already signed in." when visiting learnings page' do
      visit learnings_path

      expect(page).to have_content('Learning Lessons')
      expect(page).not_to have_content('You are already signed in.')
    end

    it 'shows learnings content when visiting root path without flash message' do
      visit '/'

      expect(page).to have_content('Learning Lessons')
      expect(page).not_to have_content('You are already signed in.')
    end

    it 'navbar logo links to learnings page' do
      visit learnings_path

      within('.navbar-brand') do
        click_link 'Learner'
      end

      expect(page).to have_current_path(learnings_path)
      expect(page).not_to have_content('You are already signed in.')
    end
  end

  describe 'unauthenticated user' do
    it 'shows sign-in page when visiting root path' do
      visit '/'

      expect(page).to have_button('Login')
      expect(page).not_to have_content('You are already signed in.')
    end

    it 'navbar logo links to sign-in page' do
      visit new_user_session_path

      within('.navbar-brand') do
        click_link 'Learner'
      end

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_button('Login')
    end

    it 'redirects to sign-in when trying to access learnings page' do
      visit learnings_path

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content(I18n.t('devise.failure.unauthenticated'))
    end
  end
end
