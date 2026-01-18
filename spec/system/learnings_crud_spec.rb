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
      expect(page).not_to have_select('Organization')

      expect(page).to have_css("input[type=\"hidden\"][id=\"learning_organization_id\"][value=\"#{organization.id}\"]",
                               visible: false)

      # Organization name should be displayed as read-only text
      expect(page).to have_css("input[disabled][readonly][value=\"#{organization.name}\"]")
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
end
