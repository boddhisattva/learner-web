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
      create_list(:learning, 25, creator: user, last_modifier: user, organization: organization)
    end

    it 'loads more learnings as user scrolls down with proper visual separation' do
      visit learnings_path

      # First page loads with correct items and total count
      expect(page).to have_text('(25 total)', wait: 5)
      expect(page).to have_content('Learning Lessons')

      # Loading indicator is present
      expect(page).to have_content('Loading more...', wait: 2)

      # Verify border separators exist between items on first page
      tables_with_borders = page.all('table[style*="border-bottom"]', wait: 2)
      expect(tables_with_borders.count).to be >= 10 # At least 10 learning items (desktop viewport)

      # Scroll to bottom to trigger lazy loading
      page.execute_script('window.scrollTo(0, document.body.scrollHeight)')
      sleep 3 # Wait for Turbo Frame to load

      # Border separators should exist across all loaded items
      tables_with_borders_after = page.all('table[style*="border-bottom"]', wait: 2)
      expect(tables_with_borders_after.count).to be >= 20 # At least 20 items loaded

      # Scroll again to load final page
      page.execute_script('window.scrollTo(0, document.body.scrollHeight)')
      sleep 3

      # Border separators across loaded items (at least 2 pages loaded)
      final_tables_with_borders = page.all('table[style*="border-bottom"]', wait: 2)
      expect(final_tables_with_borders.count).to be >= 20 # At least 20 items confirms multiple pages loaded
    end
  end

  context 'with less than one page of learnings' do
    before do
      create_list(:learning, 5, creator: user, last_modifier: user, organization: organization)
    end

    it 'displays all items without pagination controls' do
      visit learnings_path

      expect(page).to have_text('(5 total)', wait: 5)

      # No loading indicator when fewer than page size
      expect(page).not_to have_content('Loading more...')

      # Border separators still present
      tables_with_borders = page.all('table[style*="border-bottom"]', wait: 2)
      expect(tables_with_borders.count).to be >= 5 # At least 5 learning items
    end
  end

  context 'with exactly one page of learnings' do
    before do
      create_list(:learning, 10, creator: user, last_modifier: user, organization: organization)
    end

    it 'displays all items without next page indicator' do
      visit learnings_path

      expect(page).to have_text('(10 total)', wait: 5)

      # No loading indicator when exactly one page
      expect(page).not_to have_content('Loading more...')
    end
  end
end
