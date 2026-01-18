# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learnings Search', :js, type: :system do
  let(:user) { create(:user, :with_organization_and_membership) }
  let(:organization) { user.personal_organization }

  before do
    sign_in user
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
      expect(page).to have_field('query', type: 'search', placeholder: 'Type to search lessons...')

      expect(page).not_to have_link('Clear')

      expect(page).to have_content('Learning Lessons')

      fill_in 'query', with: 'Ruby'

      expect(page).to have_content('Ruby basics for beginners')
      expect(page).to have_content('Ruby on Rails deployment')
      expect(page).not_to have_content('JavaScript fundamentals')
      expect(page).not_to have_content('Rails advanced patterns')

      expect(page).to have_link('Clear')

      click_link 'Clear'

      expect(page).to have_content('Ruby basics for beginners')
      expect(page).to have_content('Rails advanced patterns')
      expect(page).to have_content('JavaScript fundamentals')
      expect(page).to have_content('Ruby on Rails deployment')

      expect(find_field('query').value).to be_blank

      expect(page).not_to have_link('Clear')
    end
  end

  describe 'searching when there are no matching learnings, no learnings exist, and Clear button' do
    it 'shows no results message when no learnings match and shows Clear button' do
      create(:learning, lesson: 'Ruby basics', creator: user, last_modifier: user)

      visit learnings_path(query: 'Ruby')

      expect(page).to have_link('Clear')
      expect(page).to have_content('Ruby basics')

      fill_in 'query', with: 'Python Programming'

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
        50.times do |i|
          create(:learning,
                 lesson: "Ruby learning #{i + 1}",
                 description: "Description for Ruby learning #{i + 1}",
                 creator: user,
                 last_modifier: user,
                 organization: organization,
                 created_at: Time.zone.now - (49 - i).minutes, # Newest first (Ruby learning 50 is most recent)
                 updated_at: Time.zone.now - (49 - i).minutes)
        end

        20.times do |i|
          create(:learning,
                 lesson: "JavaScript lesson #{i + 1}",
                 description: "Description for JavaScript lesson #{i + 1}",
                 creator: user,
                 last_modifier: user,
                 organization: organization,
                 created_at: Time.zone.now - (69 - i).minutes,
                 updated_at: Time.zone.now - (69 - i).minutes)
        end
      end

      it 'loads search results progressively as user scrolls while maintaining search filter' do
        visit learnings_path

        fill_in 'query', with: 'Ruby'

        expect(page).to have_content('Ruby learning 50')
        expect(page).not_to have_content('Ruby learning 25')
        expect(page).not_to have_content('Ruby learning 1')

        expect(page).not_to have_content('JavaScript lesson')

        scroll_until_content_appears('Ruby learning 25')
        expect(page).not_to have_content('Ruby learning 1')

        expect(page).not_to have_content('JavaScript lesson')

        scroll_until_content_appears('Ruby learning 1')

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
