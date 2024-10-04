# frozen_string_literal: true

require 'rails_helper'

module Mobile
  describe 'User sign up & sign in flow', type: :system do
    describe 'Mobile User sign up flow', :mobile_dimensions do
      let(:activity_day) { create(:activity_day) }

      before do
        page.current_window.resize_to(501, 764)
      end

      it 'returns error with invalid credentials. Creates a new user, returns welcome message with valid credentials' do
        visit '/users/sign_up'

        fill_in 'user_first_name', with: 'Racquel'
        fill_in 'user_last_name', with: 'R'
        fill_in 'user_email', with: 'racquel.r@example.com'
        fill_in 'user_password', with: 'short'

        save_and_open_page

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
end
