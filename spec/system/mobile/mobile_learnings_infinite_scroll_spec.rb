# frozen_string_literal: true

require 'rails_helper'

module Mobile
  describe 'Learnings Infinite Scroll on Mobile', type: :system do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }
    let(:membership) { create(:membership, member: user, organization: organization) }

    describe 'Mobile infinite scroll' do
      before do
        page.current_window.resize_to(501, 764) # Mobile viewport
        sleep 0.5 # Give browser time to apply viewport change
        sign_in user
        organization
        membership
      end

      after do
        page.current_window.resize_to(1200, 815) # Reset to desktop
        sleep 0.5 # Give browser time to apply viewport change
      end

      context 'with multiple pages of learnings' do
        before do
          create_list(:learning, 25, creator: user, last_modifier: user, organization: organization)
        end

        it 'loads more learnings as user scrolls on mobile with proper responsive layout' do
          visit learnings_path

          # Mobile viewport shows correct total count
          expect(page).to have_text('(25 total)', wait: 5)

          # Mobile-specific header is visible (2 columns: Lesson + Actions)
          mobile_headers = page.all('th.is-hidden-tablet', visible: true)
          expect(mobile_headers.count).to eq(2) # Two mobile headers: Lesson + Actions

          # Loading indicator present
          expect(page).to have_content('Loading more...', wait: 2)

          # Border separators work on mobile - table elements with border-bottom style
          tables_with_borders = page.all('table[style*="border-bottom"]', wait: 2)
          expect(tables_with_borders.count).to be >= 10 # At least 10 learning items (mobile viewport)

          # Mobile columns are visible
          mobile_cells = page.all('td.is-hidden-tablet', visible: true)
          expect(mobile_cells.count).to be >= 20 # At least 20 mobile cells (2 per row × 10 rows)

          # Scroll on mobile viewport
          page.execute_script('window.scrollTo(0, document.body.scrollHeight)')
          sleep 3 # Wait for lazy load

          # Second page loads with borders
          tables_after_scroll = page.all('table[style*="border-bottom"]', wait: 2)
          expect(tables_after_scroll.count).to be >= 20 # More items loaded: at least 20 items

          # Mobile layout persists after loading more pages
          mobile_cells_after = page.all('td.is-hidden-tablet', visible: true)
          expect(mobile_cells_after.count).to be >= 40 # At least 40 mobile cells (2 per row × 20 rows)

          # Desktop headers remain hidden on mobile
          desktop_headers = page.all('th.is-hidden-mobile', visible: false)
          expect(desktop_headers.count).to eq(3) # Desktop headers exist but are hidden
        end
      end

      context 'with less than one page on mobile' do
        before do
          create_list(:learning, 5, creator: user, last_modifier: user, organization: organization)
        end

        it 'displays all items in mobile layout without pagination' do
          visit learnings_path

          # Shows correct count
          expect(page).to have_text('(5 total)', wait: 5)

          # No loading indicator for single page
          expect(page).not_to have_content('Loading more...')

          # Mobile headers are visible
          mobile_headers = page.all('th.is-hidden-tablet', visible: true)
          expect(mobile_headers.count).to eq(2) # Two mobile headers: Lesson + Actions

          # Border separators present - table elements with border-bottom style
          tables_with_borders = page.all('table[style*="border-bottom"]', wait: 2)
          expect(tables_with_borders.count).to be >= 5 # At least 5 learning items

          # Mobile columns are visible
          mobile_cells = page.all('td.is-hidden-tablet', visible: true)
          expect(mobile_cells.count).to be >= 10 # At least 10 mobile cells (2 per row × 5 rows)
        end
      end
    end
  end
end
