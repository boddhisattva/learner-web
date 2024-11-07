require "rails_helper"

RSpec.describe "Learnings", type: :system do
  let(:user) { create(:user) }
  let(:learning) { create(:learning, creator: user, last_modifier: user) }

  before do
    sign_in user
  end

  describe "index page" do
    before do
      create_list(:learning, 3, creator: user, last_modifier: user)
      visit learnings_path
    end

    it "displays all learnings" do
      user_learnings = user.learnings
      expect(page).to have_content("#{user_learnings[0].lesson}")
      expect(page).to have_content("#{user_learnings[1].lesson}")
      expect(page).to have_content("#{user_learnings[2].lesson}")
    end
  end

  describe "creating a learning" do
    let(:organization) { create(:organization) }
    let(:membership) { create(:membership, member: user, organization: organization) }

    before do
      organization
      membership
      visit new_learning_path
    end

    context "with valid inputs" do
      it "creates a new learning" do
        fill_in "Lesson", with: "Test Lesson"
        fill_in "Description", with: "Test Description"
        select organization.name, from: 'Organization'

        click_button "Create Learning"

        expect(page).to have_content(I18n.t("learnings.create.success"))
        expect(page).to have_content("Test Lesson")
      end
    end

    context "with invalid inputs" do
      it "shows validation errors" do
        click_button "Create Learning"

        expect(page).to have_content("Lesson can't be blank")
      end
    end
  end

  describe "showing a learning" do
    context "when learning exists" do
      it "displays the learning details" do
        visit learning_path(learning)

        expect(page).to have_content(learning.lesson)
        expect(page).to have_content(learning.description)
      end
    end

    context "when learning doesn't exist" do
      it "redirects to index with error message" do
        visit learning_path(id: 999999)

        expect(page).to have_current_path(learnings_path)
        expect(page).to have_content("Learning not found")
      end
    end
  end

  describe "deleting a learning" do
    before do
      learning
      visit learnings_path
    end

    it "removes the learning" do
      accept_confirm do
        first(".is-danger").click
      end

      expect(page).not_to have_content(learning.lesson)
      expect(page).to have_content("Your Learning is removed successfully")
    end
  end
end
