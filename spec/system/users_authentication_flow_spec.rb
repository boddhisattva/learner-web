# frozen_string_literal: true

require 'rails_helper'

describe 'User sign up & sign in flow', type: :system do
  describe 'User sign up flow' do
    let(:activity_day) { create(:activity_day) }

    it 'returns error with invalid credentials & creates a new user & returns welcome message with valid credentials' do
      visit '/users/sign_up'

      fill_in 'user_first_name', with: 'Racquel'
      fill_in 'user_last_name', with: 'R'
      fill_in 'user_email', with: 'racquel.r@example.com'
      fill_in 'user_password', with: 'short'

      click_button 'Sign Up'

      expect(page)
        .to have_text("Password #{I18n.t ('activerecord.errors.models.user.attributes.password.too_short')}")
      expect(User.count).to eq(0)

      fill_in 'user_password', with: 'testpass768'

      click_button 'Sign Up'

      expect(page).to have_text("Welcome to #{I18n.t('learner')}, Racquel R")
      expect(User.count).to eq(1)
    end
  end
end
