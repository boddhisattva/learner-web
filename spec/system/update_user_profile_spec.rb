# frozen_string_literal: true

require 'rails_helper'

describe 'Update user profile details', type: :system do
  describe 'User sign up flow' do
    let(:user) { create(:user, first_name: '  Rachel ', last_name: ' Longwood', email: '  rachel@xyz.com ') }

    before do
      sign_in user
      # Whenever a new user is created via user sign up flow, an organization is created with user name, hence adding relevant setup
      Organization.create(name: user.name)
    end

    it 'Updates user details like first name, email etc., with valid inputs & return success message' do
      visit '/profile'

      fill_in User.human_attribute_name(:first_name), with: 'Rania'

      click_button I18n.t('users.show.save_profile')

      expect(page).to have_selector('#current_user_name', text: 'Rania Longwood')
      expect(page).to have_text(I18n.t('users.update.success'))
    end
  end
end
