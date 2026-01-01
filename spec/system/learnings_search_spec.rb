# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learnings Search', :js, type: :system do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:membership) { create(:membership, member: user, organization: organization) }

  before do
    sign_in user
    organization
    membership
  end

  describe 'complete search flow' do
    before do
      create(:learning, lesson: 'Ruby basics for beginners', creator: user, last_modifier: user)
      create(:learning, lesson: 'Rails advanced patterns', creator: user, last_modifier: user)
      create(:learning, lesson: 'JavaScript fundamentals', creator: user, last_modifier: user)
      create(:learning, lesson: 'Ruby on Rails deployment', creator: user, last_modifier: user)

      visit learnings_path
    end

    it 'shows filtered results, displays Clear button, & allows clearing to show all results' do
      # Verify search input has correct attributes (setup check)
      expect(page).to have_field('query', type: 'search', placeholder: 'Type to search lessons...')

      # Initially, no Clear button should be visible
      expect(page).not_to have_link('Clear')

      # Page heading should be present before search
      expect(page).to have_content('Learning Lessons')

      # Type in search field - triggers auto-search without clicking button
      fill_in 'query', with: 'Ruby'

      # Should see filtered results (Turbo Frame updated without page reload)
      expect(page).to have_content('Ruby basics for beginners')
      expect(page).to have_content('Ruby on Rails deployment')
      expect(page).not_to have_content('JavaScript fundamentals')
      expect(page).not_to have_content('Rails advanced patterns')

      # Clear button should appear when search is active
      expect(page).to have_link('Clear')

      # Click Clear button to reset search
      click_link 'Clear'

      # Should show all learnings again after clearing
      expect(page).to have_content('Ruby basics for beginners')
      expect(page).to have_content('Rails advanced patterns')
      expect(page).to have_content('JavaScript fundamentals')
      expect(page).to have_content('Ruby on Rails deployment')

      # Search field should be empty after clearing
      expect(find_field('query').value).to be_blank

      # Clear button should disappear after clearing
      expect(page).not_to have_link('Clear')
    end
  end

  describe 'search with infinite scroll pagination' do
    before do
      15.times do |i|
        create(:learning, lesson: "New learning test #{i + 1}", creator: user, last_modifier: user)
      end

      10.times do |i|
        create(:learning, lesson: "Different topic #{i + 1}", creator: user, last_modifier: user)
      end

      visit learnings_path
    end
  end

  describe 'searching when there are no matching learnings, no learnings exist, and Clear button' do
    it 'shows no results message when no learnings match and shows Clear button' do
      # Setup: Create a learning for testing
      create(:learning, lesson: 'Ruby basics', creator: user, last_modifier: user)

      # Visit search page with query parameter (simulates bookmarked search URL)
      visit learnings_path(query: 'Ruby')

      # Clear button should be visible when visiting with query param
      expect(page).to have_link('Clear')
      expect(page).to have_content('Ruby basics')

      # Search for something that doesn't exist
      fill_in 'query', with: 'Python Programming'

      # Should show "no results found" message
      expect(page).to have_content('No learnings found matching "Python Programming"')

    end

    it 'shows empty state when no learnings exist' do
      Learning.destroy_all
      visit learnings_path

      expect(page).to have_content('No learnings have been created yet')
      expect(page).to have_link('Create your first learning')
      expect(page).not_to have_content('No learnings found matching')

    end
  end

  describe 'progressive loading of search results' do
    context 'with multiple pages of search results' do
      before do
        # Create 50 learnings matching "Ruby" search
        # Pagy limit is 10, so this creates 5 pages of matching results
        # With enough data, not all pages will auto-load on initial visit
        ruby_learnings = Array.new(50) do |i|
          {
            lesson: "Ruby learning #{i + 1}",
            description: "Description for Ruby learning #{i + 1}",
            creator_id: user.id,
            last_modifier_id: user.id,
            organization_id: organization.id,
            public_visibility: false,
            learning_category_ids: [],
            created_at: Time.zone.now - (49 - i).minutes, # Newest first (Ruby learning 50 is most recent)
            updated_at: Time.zone.now - (49 - i).minutes
          }
        end

        # Create 20 learnings that DON'T match search (should never appear)
        non_matching_learnings = Array.new(20) do |i|
          {
            lesson: "JavaScript lesson #{i + 1}",
            description: "Description for JavaScript lesson #{i + 1}",
            creator_id: user.id,
            last_modifier_id: user.id,
            organization_id: organization.id,
            public_visibility: false,
            learning_category_ids: [],
            created_at: Time.zone.now - (69 - i).minutes,
            updated_at: Time.zone.now - (69 - i).minutes
          }
        end

        # rubocop:disable Rails/SkipsModelValidations
        Learning.insert_all(ruby_learnings + non_matching_learnings)
        # rubocop:enable Rails/SkipsModelValidations
      end

      it 'loads search results progressively as user scrolls while maintaining search filter' do
        visit learnings_path

        # Search for "Ruby" - should match 50 learnings (5 pages)
        fill_in 'query', with: 'Ruby'

        # Initial page shows newest matching results (page 1)
        expect(page).to have_content('Ruby learning 50')
        expect(page).not_to have_content('Ruby learning 25')
        expect(page).not_to have_content('Ruby learning 1')

        # Non-matching results should NEVER appear
        expect(page).not_to have_content('JavaScript lesson')

        # Scroll until we see a middle page item (around page 3)
        scroll_until_content_appears('Ruby learning 25')
        expect(page).not_to have_content('Ruby learning 1')

        # Still no JavaScript results
        expect(page).not_to have_content('JavaScript lesson')

        # Scroll until we see the oldest matching item (all pages loaded)
        scroll_until_content_appears('Ruby learning 1')

        # Verify JavaScript results still don't appear even after all scrolling
        expect(page).not_to have_content('JavaScript lesson')
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
end
