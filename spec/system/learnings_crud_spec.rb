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

  describe 'showing a learning' do
    context 'when learning exists' do
      before do
        learning
      end

      it 'displays the learning details', bullet: :skip do
        visit learning_path(learning)

        expect(page).to have_content(learning.lesson)
        expect(page).to have_content(learning.description)
        expect(page).to have_content('Organization Details')
        expect(page).to have_content(organization.name)
      end
    end
  end
end
