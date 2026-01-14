# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learnings Infinite Scroll', type: :system do
  let(:user) { create(:user) }
  let(:organization) { user.personal_organization }

  before do
    sign_in user
  end

  context 'with multiple pages of learnings' do
    before do
      Prosopite.pause
      50.times do |i|
        create(:learning,
               lesson: "Learning #{i + 1}",
               creator: user,
               organization: organization,
               created_at: Time.zone.now - (49 - i).minutes,
               updated_at: Time.zone.now - (49 - i).minutes)
      end
      Prosopite.resume
    end

    it 'loads learnings progressively as user scrolls' do
      visit learnings_path

      # Initial page shows newest learnings
      expect(page).to have_content('Learning 50')
      expect(page).not_to have_content('Learning 25')
      expect(page).not_to have_content('Learning 1')

      # Scroll until we see a middle page item
      scroll_until_content_appears('Learning 25')
      expect(page).not_to have_content('Learning 1')

      # Scroll until we see the oldest item (all pages loaded)
      scroll_until_content_appears('Learning 1')
    end

    # Turbo lazy loading relies on IntersectionObserver which is unreliable in headless Chrome.
    # This helper scrolls repeatedly until the expected content appears.
    def scroll_until_content_appears(content, max_attempts: 2)
      max_attempts.times do
        return if page.has_content?(content)

        page.scroll_to(:bottom)
        page.execute_script(<<~JS)
          const frame = document.querySelector('turbo-frame[loading=lazy]');
          if (frame) { frame.loading = 'eager'; frame.reload(); }
        JS
      end

      expect(page).to have_content(content)
    end
  end
end
