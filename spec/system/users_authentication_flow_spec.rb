# frozen_string_literal: true

require 'rails_helper'

describe 'User sign up & sign in flow', type: :system do
  describe 'User sign up flow' do
    it 'Returns error with invalid credentials' do
      visit '/users/sign_up'

      fill_in User.human_attribute_name(:first_name), with: 'Racquel'
      fill_in User.human_attribute_name(:last_name), with: 'R'
      fill_in User.human_attribute_name(:email), with: 'racquel.r@example.com'
      fill_in User.human_attribute_name(:password), with: 'short'

      click_button 'Sign Up'

      expect(page)
        .to have_text("Password #{I18n.t('activerecord.errors.models.user.attributes.password.too_short')}")
      expect(User.count).to eq(0)
    end

    it 'Creates & logs in new user with a message with valid credentials.' do
      visit '/users/sign_up'

      fill_in User.human_attribute_name(:first_name), with: 'Racquel'
      fill_in User.human_attribute_name(:last_name), with: 'R'
      fill_in User.human_attribute_name(:email), with: 'racquel.r@example.com'
      fill_in User.human_attribute_name(:password), with: 'testpass768'

      click_button 'Sign Up'

      expect(page).to have_text('Learning Lessons') # Confirms Sign in on Signup
      expect(page).to have_text(I18n.t('users.create.welcome', name: 'Racquel R'))
      expect(User.count).to eq(1)
    end
  end

  describe 'User sign in flow' do
    before do
      create(:user, first_name: '  Rachel ', last_name: ' Longwood', email: '  rachel@xyz.com ')
    end

    it 'returns error with invalid credentials & logs in user with correct credentials' do
      visit '/users/sign_in'

      fill_in User.human_attribute_name(:email), with: 'rachel@xyz.com'
      fill_in User.human_attribute_name(:password), with: 'random invalid password'

      click_button 'Login'

      expect(page).to have_text(I18n.t('devise.failure.invalid', authentication_keys: 'Email'))

      fill_in User.human_attribute_name(:password), with: 'MyString'

      click_button 'Login'

      expect(page).to have_text(I18n.t('devise.sessions.signed_in'))
    end
  end
end
