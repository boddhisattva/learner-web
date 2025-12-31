# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learnings', type: :system do
  let(:user) { create(:user) }
  let(:learning) { create(:learning, creator: user, last_modifier: user) }
  let(:organization) { create(:organization) }
  let(:membership) { create(:membership, member: user, organization: organization) }

  before do
    sign_in user
    organization
    membership
  end

  describe 'index page' do
    before do
      create_list(:learning, 3, creator: user, last_modifier: user)
      visit learnings_path
    end

    it 'displays all learnings' do
      user_learnings = user.learnings
      expect(page).to have_content(user_learnings[0].lesson.to_s)
      expect(page).to have_content(user_learnings[1].lesson.to_s)
      expect(page).to have_content(user_learnings[2].lesson.to_s)
    end
  end

  describe 'creating a learning' do

    before do
      visit new_learning_path
    end

    context 'with valid inputs' do
      it 'creates a new learning' do
        fill_in 'Lesson', with: 'Test Lesson'
        fill_in 'Description', with: 'Test Description'
        select organization.name, from: 'Organization'

        click_button 'Create Learning'

        expect(page).to have_content(I18n.t('learnings.create.success', lesson: 'Test Lesson'))
        expect(page).to have_content('Test Lesson')
      end
    end

    context 'with invalid inputs' do
      it 'shows validation errors' do
        click_button 'Create Learning'

        expect(page).to have_content("Lesson can't be blank")
      end
    end
  end

  describe 'showing a learning' do
    context 'when learning exists' do
      it 'displays the learning details' do
        visit learning_path(learning)

        expect(page).to have_content(learning.lesson)
        expect(page).to have_content(learning.description)
      end
    end

    context "when learning doesn't exist" do
      it 'redirects to index with error message' do
        visit learning_path(id: 999_999)

        expect(page).to have_current_path(learnings_path)
        expect(page).to have_content('Learning not found')
      end
    end
  end

  describe 'deleting a learning' do
    before do
      learning
      visit learnings_path
    end

    it 'removes the learning' do
      accept_confirm do
        first('.is-danger').click
      end

      within('#all_learnings') do
        expect(page).not_to have_content(learning.lesson)
      end
      expect(page).to have_content(I18n.t('learnings.destroy.success', lesson: learning.lesson))
    end
  end

  describe 'editing a learning' do
    before do
      learning
      visit edit_learning_path(learning)
    end

    context 'with valid inputs' do
      it 'updates the learning' do
        fill_in 'Lesson', with: 'Updated Lesson'
        fill_in 'Description', with: 'Updated Description'

        click_button 'Update Learning'

        expect(page).to have_content(I18n.t('learnings.update.success', lesson: 'Updated Lesson'))
        expect(page).to have_content('Updated Lesson')
        expect(page).to have_content('Updated Description')
      end
    end

    context 'with invalid inputs' do
      it 'shows validation errors' do
        fill_in 'Lesson', with: ''
        click_button 'Update Learning'

        expect(page).to have_content("Lesson can't be blank")
      end
    end

    context "when learning doesn't exist" do
      it 'redirects to index with error message' do
        visit edit_learning_path(id: 999_999)

        expect(page).to have_current_path(learnings_path)
        expect(page).to have_content(I18n.t('learnings.edit.not_found'))
      end
    end
  end
end
