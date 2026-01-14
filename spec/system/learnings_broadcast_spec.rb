# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learnings Broadcasting', type: :system do
  include ActiveJob::TestHelper

  let(:organization) { create(:organization, name: 'Earth') }
  let(:user_a) { create(:user, first_name: 'Alice', last_name: 'Anderson') }
  let(:user_b) { create(:user, first_name: 'Bob', last_name: 'Builder') }

  before do
    create(:membership, member: user_a, organization: organization)
    create(:membership, member: user_b, organization: organization)
  end

  describe 'broadcasting organization learnings', :js do
    it 'displays new organization learning to other members in real-time' do
      create(:learning, lesson: 'Existing Learning', visibility: :organization, creator: user_a, last_modifier: user_a,
                        organization: organization)
      sign_in_with_organization(user_b, organization)
      visit learnings_path

      expect(page).to have_content('Existing Learning')
      expect(page).not_to have_content('Team Standup Notes')

      Capybara.using_session('User A session') do
        sign_in_with_organization(user_a, organization)
        visit learnings_path

        click_link 'New Learning'

        fill_in placeholder: 'Enter learning name', with: 'Team Standup Notes'
        fill_in placeholder: 'Enter learning description', with: 'Daily standup notes'
        choose 'Organization'
        click_button 'Create Learning'

        expect(page).to have_content('Your Learning "Team Standup Notes" is created successfully')
      end

      expect(page).to have_content('Team Standup Notes')
    end

    it 'does NOT display personal learnings to other members in real-time' do
      sign_in_with_organization(user_b, organization)
      visit learnings_path

      expect(page).to have_content('Learning Lessons')

      Capybara.using_session('User A session') do
        sign_in_with_organization(user_a, organization)
        visit learnings_path

        click_link 'New Learning'

        fill_in placeholder: 'Enter learning name', with: 'Personal Note by Alice'
        fill_in placeholder: 'Enter learning description', with: 'Private notes'

        choose 'Personal'
        click_button 'Create Learning'

        expect(page).to have_content('Your Learning "Personal Note by Alice" is created successfully')
      end

      expect(page).not_to have_content('Personal Note by Alice')
    end

    it 'displays updated organization learning to other members in real-time' do
      learning = create(:learning,
                        lesson: 'Original Lesson',
                        description: 'Original description',
                        visibility: :organization,
                        creator: user_a,
                        last_modifier: user_a,
                        organization: organization)

      sign_in_with_organization(user_b, organization)
      visit learnings_path

      expect(page).to have_content('Original Lesson')
      expect(page).not_to have_content('Updated Lesson')

      # User A updates the learning in a separate session
      Capybara.using_session('User A session') do
        sign_in_with_organization(user_a, organization)
        visit edit_learning_path(learning)

        fill_in 'learning_lesson', with: 'Updated Lesson'
        click_button 'Update Learning'

        expect(page).to have_content('Your Learning "Updated Lesson" is updated successfully')
      end

      # User B should see the updated learning via broadcast
      expect(page).to have_content('Updated Lesson')
      expect(page).not_to have_content('Original Lesson')
    end
  end

  describe 'visibility scoping' do
    before do
      # Create various learnings with different visibilities
      @personal_by_a = create(:learning,
                              lesson: 'Personal by Alice',
                              visibility: :personal,
                              creator: user_a,
                              last_modifier: user_a,
                              organization: organization)

      @org_by_a = create(:learning,
                         lesson: 'Organization by Alice',
                         visibility: :organization,
                         creator: user_a,
                         last_modifier: user_a,
                         organization: organization)

      @open_by_a = create(:learning,
                          lesson: 'Open by Alice',
                          visibility: :open,
                          creator: user_a,
                          last_modifier: user_a,
                          organization: organization)

      @personal_by_b = create(:learning,
                              lesson: 'Personal by Bob',
                              visibility: :personal,
                              creator: user_b,
                              last_modifier: user_b,
                              organization: organization)
    end

    it 'shows correct learnings to User B (organization and open, not personal by others)', :js do
      sign_in_with_organization(user_b, organization)
      visit learnings_path

      expect(page).to have_content('Organization by Alice')
      expect(page).to have_content('Open by Alice')

      expect(page).to have_content('Personal by Bob')

      expect(page).not_to have_content('Personal by Alice')
    end

    it 'shows correct learnings to User A (all their learnings plus org/open)', :js do
      sign_in_with_organization(user_a, organization)
      visit learnings_path

      expect(page).to have_content('Personal by Alice')
      expect(page).to have_content('Organization by Alice')
      expect(page).to have_content('Open by Alice')

      expect(page).not_to have_content('Personal by Bob')
    end
  end
end
