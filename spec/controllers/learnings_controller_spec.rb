require "rails_helper"

RSpec.describe LearningsController, type: :controller do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:learning_category) { create(:learning_category) }

  before { sign_in user }

  describe "GET #index" do
    let!(:learning) { create(:learning, creator: user) }
    let!(:other_user_learning) { create(:learning) }

    it "lists only the current user's learnings" do
      get :index
      expect(assigns(:learnings)).to include(learning)
      expect(assigns(:learnings)).not_to include(other_user_learning)
    end
  end

  describe "GET #new" do
    it "initializes a new learning" do
      get :new
      expect(assigns(:learning)).to be_a_new(Learning)
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        learning: {
          lesson: "Test Lesson",
          description: "Test Description",
          public: true,
          organization_id: organization.id,
          learning_category_ids: [ learning_category.id ]
        }
      }
    end

    context "with valid parameters" do
      it "creates a new learning, sets the attributes and redirects to index with success message" do
        post :create, params: valid_params
        learning = Learning.last

        expect {
          post :create, params: valid_params
        }.to change(Learning, :count).by(1)

        expect(learning.lesson).to eq("Test Lesson")
        expect(learning.description).to eq("Test Description")
        expect(learning.public).to eq(true)
        expect(learning.organization).to eq(organization)
        expect(learning.learning_category_ids).to eq([ learning_category.id ])
        expect(learning.creator).to eq(user)
        expect(learning.last_modifier).to eq(user)

        expect(response).to redirect_to(learnings_index_path)
        expect(flash[:success]).to eq(I18n.t("learnings.create.success"))
      end

    end

    context "with invalid parameters" do
      let(:invalid_params) { { learning: { lesson: "" } } }

      it "does not create a new learning, renders new template with error message" do
        expect {
          post :create, params: invalid_params
        }.not_to change(Learning, :count)

        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(flash.now[:error]).to eq([ "Lesson can't be blank", "Organization must exist" ])
      end
    end
  end

  describe "GET #show" do
    let(:learning) { create(:learning, creator: user) }

    it "assigns the requested learning" do
      get :show, params: { id: learning.id }
      expect(assigns(:learning)).to eq(learning)
    end

    context "when the learning is not found" do
      it "redirects to index with error message" do
        get :show, params: { id: 'nonexistent' }
        expect(response).to redirect_to(learnings_index_path)
        expect(flash[:error]).to eq(I18n.t("learnings.show.error"))
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:learning) { create(:learning, creator: user) }

    context "with Turbo Stream request", as: :turbo_stream do
      before { request.accept = "text/vnd.turbo-stream.html" }

      it "deletes the learning" do
        expect {
          delete :destroy, params: { id: learning.id }
        }.to change(Learning, :count).by(-1)
      end

      it "returns success status and renders destroy template" do
        delete :destroy, params: { id: learning.id }
        expect(response).to have_http_status(:see_other)
        expect(response).to render_template(:destroy)
        expect(flash.now[:success]).to eq(I18n.t("learnings.destroy.success"))
      end
    end

    context "with HTML request" do
      it "redirects to index with success message" do
        expect {
          delete :destroy, params: { id: learning.id }
        }.to change(Learning, :count).by(-1)
        expect(response).to redirect_to(learnings_index_path)
        expect(response).to have_http_status(:see_other)
        expect(flash[:success]).to eq(I18n.t("learnings.destroy.success"))
      end
    end

    context "when destroy fails" do
      before do
        allow_any_instance_of(Learning).to receive(:destroy).and_return(false)
        allow_any_instance_of(Learning).to receive(:errors).and_return(
          double(full_messages: [ "Error message" ])
        )
      end

      it "learning to be deleted is not found" do
        expect {
          delete :destroy, params: { id: 'nonexistent' }
        }.not_to change(Learning, :count)
        expect(flash.now[:error]).to eq(I18n.t("learnings.destroy.not_found"))
      end

      it "sets error flash message" do
        expect {
          delete :destroy, params: { id: learning.id }
        }.not_to change(Learning, :count)
        expect(flash.now[:error]).to eq([ "Error message" ])
        expect(response).to redirect_to(learnings_index_path)
        expect(response).to have_http_status(:see_other)
      end
    end
  end
end
