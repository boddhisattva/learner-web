# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learnings Show with Turbo Frame', :js do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:membership) { create(:membership, user: user, organization: organization) }
  let!(:learning) do
    create(:learning,
           lesson: 'Understanding Turbo Frames',
           description: 'Learn how Turbo Frames work in Rails',
           organization: organization,
           creator: user,
           last_modifier: user)
  end

  before do
    membership
    sign_in user
    visit learnings_path
  end

  describe 'clicking the show (eye) button' do
    it 'displays learning details inline within the Turbo Frame' do
      # Verify we're on the learnings index page
      expect(page).to have_current_path(learnings_path)
      expect(page).to have_content('Understanding Turbo Frames')

      # Find the turbo frame for this learning
      within("##{dom_id(learning)}") do
        # Click the show button (eye icon)
        find('a.button.is-info.is-small').click
      end

      # Wait for Turbo Frame to update
      sleep 0.5

      # The frame should still exist with the same ID
      expect(page).to have_css("##{dom_id(learning)}")

      # Should not navigate away from index page
      expect(page).to have_current_path(learnings_path)

      # The content should be updated within the frame
      within("##{dom_id(learning)}") do
        # Should still show the lesson name
        expect(page).to have_content('Understanding Turbo Frames')

        # Should have action buttons
        expect(page).to have_css('a.button.is-info.is-small') # Show button
        expect(page).to have_css('a.button.is-warning.is-small') # Edit button
      end
    end

    it 'does not perform a full page reload' do
      # Get the initial page title to verify no full reload happens
      initial_title = page.title

      within("##{dom_id(learning)}") do
        find('a.button.is-info.is-small').click
      end

      sleep 0.5

      # Title should remain the same (no full page reload)
      expect(page.title).to eq(initial_title)
      expect(page).to have_current_path(learnings_path)
    end
  end

  describe 'direct navigation to show page' do
    it 'renders the full show page without Turbo Frame' do
      # Navigate directly to the show page
      visit learning_path(learning)

      # Should be on the show page
      expect(page).to have_current_path(learning_path(learning))

      # Should show full page content
      expect(page).to have_content('Understanding Turbo Frames')
      expect(page).to have_content('Learning Description')
      expect(page).to have_content('Categories')
      expect(page).to have_content('Organization Details')
      expect(page).to have_content('Audit Information')
    end
  end
end
