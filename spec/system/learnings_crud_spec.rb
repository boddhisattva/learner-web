# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Learnings', type: :system do
  let(:user) { create(:user, :with_organization_and_membership) }
  let(:organization) { user.personal_organization }
  let(:learning) { create(:learning, creator: user, last_modifier: user, organization: organization) }
  let(:discipline_category) { create(:learning_category, name: 'Discipline', creator: user, organization: organization) }
  let(:life_category) { create(:learning_category, name: 'Learnings for Life', creator: user, organization: organization) }

  before do
    sign_in user
    discipline_category
    life_category
  end

  describe 'index page' do
    before do
      create_list(:learning, 3, creator: user, last_modifier: user, organization: organization)
      visit learnings_path
    end

    it 'displays all learnings corresponding to the user current organization' do
      user_learnings = user.learnings.where(organization: organization)
      expect(page).to have_content(user_learnings[0].lesson.to_s)
      expect(page).to have_content(user_learnings[1].lesson.to_s)
      expect(page).to have_content(user_learnings[2].lesson.to_s)
    end
  end

  describe 'creating a learning' do

    before do
      visit new_learning_path
    end

    it 'displays organization as read-only and auto-assigns current organization' do
      # Organization dropdown should not exist
      expect(page).not_to have_select('Organization')

      # Hidden field should exist with correct organization ID
      expect(page).to have_css("input[type=\"hidden\"][id=\"learning_organization_id\"][value=\"#{organization.id}\"]",
                               visible: false)

      # Organization name should be displayed as read-only text
      expect(page).to have_css("input[disabled][readonly][value=\"#{organization.name}\"]")
    end

    context 'with valid inputs' do
      it 'creates a new learning with auto-assigned organization' do
        fill_in 'Lesson', with: 'Test Lesson'
        fill_in 'Description', with: 'Test Description'

        click_button 'Create Learning'

        expect(page).to have_content(I18n.t('learnings.create.success', lesson: 'Test Lesson'))
        expect(page).to have_content('Test Lesson')

        # Verify the learning was created with correct organization
        created_learning = Learning.find_by(lesson: 'Test Lesson')
        expect(created_learning.organization_id).to eq(organization.id)
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
      before do
        learning
      end

      it 'displays the learning details', bullet: :skip do
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
    let(:learning_with_category) do
      create(:learning,
             creator: user,
             last_modifier: user,
             organization: organization,
             category_ids: [discipline_category.id])
    end

    before do
      learning_with_category
      visit edit_learning_path(learning_with_category)
    end

    context 'with valid inputs' do
      it 'updates the learning and pre-selects existing category checkboxes, allows updating categories', bullet: :skip do
        # Verify existing category is pre-selected & already in the database
        expect(learning_with_category.category_ids).to include(discipline_category.id)
        expect(page).to have_checked_field("learning_category_#{discipline_category.id}")
        expect(page).to have_unchecked_field("learning_category_#{life_category.id}")

        # Update the learning
        fill_in 'Lesson', with: 'Updated Lesson'
        fill_in 'Description', with: 'Updated Description'
        check "learning_category_#{life_category.id}"

        click_button 'Update Learning'

        expect(page).to have_content(I18n.t('learnings.update.success', lesson: 'Updated Lesson'))
        expect(page).to have_content('Updated Lesson')
        expect(page).to have_content('Updated Description')

        learning_with_category.reload
        expect(learning_with_category.category_ids).to include(discipline_category.id, life_category.id)
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
        expect(page).to have_content(I18n.t('learnings.not_found'))
      end
    end
  end
end
