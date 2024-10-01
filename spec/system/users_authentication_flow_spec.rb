# frozen_string_literal: true

require 'rails_helper'

describe 'User sign up & sign in flow', type: :system do
  describe 'User sign up flow' do
    let(:activity_day) { create(:activity_day) }

    context 'with valid login credentials' do
      it 'creates a new user and redirects with appropriate success message' do
        visit '/users/sign_up'

        fill_in 'user_first_name', with: 'Racquel'
        fill_in 'user_last_name', with: 'R'
        fill_in 'user_email', with: 'racquel.r@example.com'
        fill_in 'user_password', with: 'tester876'

        click_button 'Sign Up'

        #TODO: Make sure to add an expectation that for successful sign User count increases by 1

        expect(page).to have_text("Welcome to #{I18n.t('learner')}, Racquel R")
      end
    end
  end
end
