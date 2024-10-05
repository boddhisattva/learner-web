# frozen_string_literal: true

require 'rails_helper'

module Mobile
  describe 'User sign up & sign in flow', type: :system do
    describe 'Mobile User sign up flow' do
      let(:activity_day) { create(:activity_day) }

      before do
        page.current_window.resize_to(501, 764) # Resize window to a size similar to that of mobile devices
      end

      it 'can access mobile sign up page via burger menu' do
        visit root_path

        find(".navbar-burger").click
        click_on I18n.t("shared.navbar.sign_up")

        expect(page).to have_current_path(new_user_registration_path)
      end

      it 'can access mobile login page via burger menu' do
        visit root_path

        find(".navbar-burger").click
        click_link I18n.t("shared.navbar.login")

        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end
