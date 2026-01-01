# frozen_string_literal: true

require 'rails_helper'

module Mobile
  describe 'Learnings flow in mobile', type: :system do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }
    let(:membership) { create(:membership, member: user, organization: organization) }

    describe 'Learnings CRUD' do

      before do
        page.current_window.resize_to(501, 764) # Resize window to a size similar to that of mobile devices
        sign_in user
        organization
        membership
      end

      after do
        page.current_window.resize_to(1200, 815) # Resize to normal window size defaults
      end

      context 'when creating a new learning' do

        it 'can create a new learning via mobile interface' do
          visit new_learning_path

          fill_in 'learning[lesson]', with: 'Mobile Test Learning'
          fill_in 'learning[description]', with: 'Created from mobile view'
          select organization.name, from: 'Organization'
          click_button 'Create Learning'

          expect(page).to have_content('Mobile Test Learning')
          expect(page).to have_content(I18n.t('learnings.create.success', lesson: 'Mobile Test Learning'))
        end
      end

      context 'when viewing a learning' do
        let(:learning) { create(:learning, lesson: 'Existing Learning', description: 'Test Description', creator: user) }

        it 'can view learning details via mobile interface' do
          visit learning_path(learning)

          expect(page).to have_content('Existing Learning')
          expect(page).to have_content('Test Description')
        end
      end

      context 'when updating a learning' do
        let(:learning) { create(:learning, lesson: 'Original Learning', description: 'Original Description', creator: user) }

        it 'can edit a learning via mobile interface' do
          visit edit_learning_path(learning)

          fill_in 'learning[lesson]', with: 'Updated Learning'
          fill_in 'learning[description]', with: 'Updated Description'
          click_button 'Update Learning'

          expect(page).to have_content('Updated Learning')
          expect(page).to have_content(I18n.t('learnings.update.success', lesson: 'Updated Learning'))
        end
      end

      context 'when deleting a learning' do
        let(:learning) { create(:learning, lesson: 'Learning to Delete', description: 'Will be deleted', creator: user) }

        before do
          learning
        end

        it 'can delete a learning via mobile interface' do
          visit learnings_path

          expect(page).to have_content('Learning to Delete')

          accept_confirm do
            first('.is-danger').click
          end

          expect(page).to have_content(I18n.t('learnings.destroy.success', lesson: learning.lesson))
          within('#all_learnings') do
            expect(page).not_to have_content('Learning to Delete')
          end
        end
      end
    end
  end
end
