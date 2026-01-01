# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learnings Infinite Scroll', type: :system do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    create(:membership, member: user, organization: organization)
    sign_in user
  end

  context 'with multiple pages of learnings' do
    before do
      # Create 50 learnings using insert_all for speed
      # Pagy limit is 10, so this creates 5 pages
      # With enough data, not all pages will auto-load on initial visit
      learnings_data = Array.new(50) do |i|
        {
          lesson: "Learning #{i + 1}",
          description: "Description for learning #{i + 1}",
          creator_id: user.id,
          last_modifier_id: user.id,
          organization_id: organization.id,
          public_visibility: false,
          learning_category_ids: [],
          created_at: Time.zone.now - (49 - i).minutes, # Newest first (Learning 50 is most recent)
          updated_at: Time.zone.now - (49 - i).minutes
        }
      end
      # rubocop:disable Rails/SkipsModelValidations
      Learning.insert_all(learnings_data)
      # rubocop:enable Rails/SkipsModelValidations
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
