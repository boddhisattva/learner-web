# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LearningsController, type: :controller do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }
  let(:learning_category) { create(:learning_category) }

  before { sign_in user }

  describe 'GET #index' do
    let(:learning) { create(:learning, creator: user) }
    let(:other_user_learning) { create(:learning) }

    before do
      learning
      other_user_learning
    end

    it "lists only the current user's learnings" do
      get :index
      expect(assigns(:learnings)).to include(learning)
      expect(assigns(:learnings)).not_to include(other_user_learning)
    end

    context 'with pagination' do
      before do
        create_list(:learning, 25, creator: user)
      end

      it 'sets up pagination with correct first page of results' do
        get :index

        expect(assigns(:pagy)).to be_present
        expect(assigns(:pagy).page).to eq(1)
        expect(assigns(:pagy).count).to eq(26) # 25 + 1 from let!
        expect(assigns(:pagy).pages).to eq(3)
        expect(assigns(:learnings).count).to eq(10)
      end

      it 'returns correct page when page parameter is provided' do
        get :index, params: { page: 2 }

        expect(assigns(:pagy)).to be_present
        expect(assigns(:pagy).page).to eq(2)
        expect(assigns(:pagy).next).to eq(3)
        expect(assigns(:learnings).count).to eq(10)
      end

      it 'returns only the page partial for Turbo Frame requests' do
        request.headers['Turbo-Frame'] = 'learning_page_2'
        get :index, params: { page: 2 }

        expect(response).to render_template(partial: '_learnings_page')
        expect(response).not_to render_template(layout: 'application')
      end
    end

    context 'with search query parameter' do
      it 'paginates only the filtered search results' do
        15.times { |i| create(:learning, lesson: "New learning test #{i + 1}", creator: user) }
        10.times { |i| create(:learning, lesson: "Different topic #{i + 1}", creator: user) }

        get :index, params: { query: 'New learning', page: 1 }

        expect(assigns(:pagy).count).to eq(15)
        expect(assigns(:learnings).count).to eq(10)
        expect(assigns(:learnings).map(&:lesson)).to all(match(/New learning/))
      end

      it 'preserves query parameter when paginating search results' do
        15.times { |i| create(:learning, lesson: "Test learning #{i + 1}", creator: user) }

        get :index, params: { query: 'Test', page: 2 }

        expect(assigns(:pagy).page).to eq(2)
        expect(assigns(:learnings).map(&:lesson)).to all(match(/Test/))
      end
    end
  end

  describe 'GET #new' do
    it 'initializes a new learning' do
      get :new
      expect(assigns(:learning)).to be_a_new(Learning)
    end
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        learning: {
          lesson: 'Test Lesson',
          description: 'Test Description',
          public_visibility: true,
          organization_id: organization.id,
          learning_category_ids: [learning_category.id]
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new learning, sets the attributes and redirects to index with success message' do
        post :create, params: valid_params
        learning = Learning.last

        expect do
          post :create, params: valid_params
        end.to change(Learning, :count).by(1)

        expect(learning.lesson).to eq('Test Lesson')
        expect(learning.description).to eq('Test Description')
        expect(learning.public_visibility).to be(true)
        expect(learning.organization).to eq(organization)
        expect(learning.learning_category_ids).to eq([learning_category.id])
        expect(learning.creator).to eq(user)
        expect(learning.last_modifier).to eq(user)

        expect(response).to redirect_to(learnings_path)
        expect(flash[:success]).to eq(I18n.t('learnings.create.success', lesson: learning.lesson))
      end

    end

    context 'with invalid parameters' do
      let(:invalid_params) { { learning: { lesson: '' } } }

      it 'does not create a new learning, renders new template with error message' do
        expect do
          post :create, params: invalid_params
        end.not_to change(Learning, :count)

        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(flash.now[:error]).to eq(["Lesson can't be blank", 'Organization must exist'])
      end
    end
  end

  describe 'GET #show' do
    let(:learning) { create(:learning, creator: user) }

    it 'assigns the requested learning' do
      get :show, params: { id: learning.id }
      expect(assigns(:learning)).to eq(learning)
    end

    context 'when the learning is not found' do
      it 'redirects to index with error message' do
        get :show, params: { id: 'nonexistent' }
        expect(response).to redirect_to(learnings_path)
        expect(flash[:error]).to eq(I18n.t('learnings.show.error'))
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:learning) { create(:learning, creator: user) }

    context 'with Turbo Stream request' do
      before do
        learning
        create_list(:learning, 3, creator: user)
      end

      it 'deletes the learning, sets up pagination for re-render, and returns success' do
        learning_name = learning.lesson
        expect do
          delete :destroy, params: { id: learning.id }, as: :turbo_stream
        end.to change(Learning, :count).by(-1)

        expect(assigns(:pagy)).to be_present
        expect(assigns(:learnings).count).to eq(3)
        expect(response).to have_http_status(:see_other)
        expect(response).to render_template(:destroy)
        expect(flash.now[:success]).to eq(I18n.t('learnings.destroy.success', lesson: learning_name))
      end
    end

    context 'with HTML request' do
      before { learning }

      it 'redirects to index with success message' do
        learning_name = learning.lesson
        expect do
          delete :destroy, params: { id: learning.id }
        end.to change(Learning, :count).by(-1)
        expect(response).to redirect_to(learnings_path)
        expect(response).to have_http_status(:see_other)
        expect(flash[:success]).to eq(I18n.t('learnings.destroy.success', lesson: learning_name))
      end
    end

    context 'when destroy fails' do
      before do
        learning
        # rubocop:disable RSpec / AnyInstance
        allow_any_instance_of(Learning).to receive(:destroy).and_return(false)
        allow_any_instance_of(Learning).to receive(:errors).and_return(
          double(full_messages: ['Error message'])
        )
        # rubocop:enable RSpec / AnyInstance
      end

      it 'learning to be deleted is not found' do
        expect do
          delete :destroy, params: { id: 'nonexistent' }
        end.not_to change(Learning, :count)
        expect(flash.now[:error]).to eq(I18n.t('learnings.destroy.not_found'))
      end

      it 'sets error flash message' do
        expect do
          delete :destroy, params: { id: learning.id }
        end.not_to change(Learning, :count)
        expect(flash.now[:error]).to eq(['Error message'])
        expect(response).to redirect_to(learnings_path)
        expect(response).to have_http_status(:see_other)
      end
    end
  end

  describe 'GET #edit' do
    let(:learning) { create(:learning, creator: user) }

    it 'assigns the requested learning' do
      get :edit, params: { id: learning.id }
      expect(assigns(:learning)).to eq(learning)
    end

    context 'when the learning is not found' do
      it 'redirects to index with error message' do
        get :edit, params: { id: 'nonexistent' }
        expect(response).to redirect_to(learnings_path)
        expect(flash[:error]).to eq(I18n.t('learnings.edit.not_found'))
      end
    end

    context 'when user tries to edit another users learning' do
      let(:alice) { create(:user) }
      let(:bob) { create(:user) }
      let(:alice_learning) { create(:learning, creator: alice) }

      before do
        sign_in bob
      end

      it 'redirects to learnings path with error message' do
        get :edit, params: { id: alice_learning.id }

        expect(response).to redirect_to(learnings_path)
        expect(flash[:error]).to eq(I18n.t('learnings.edit.not_found'))
      end
    end
  end

  describe 'PATCH #update' do
    let(:learning) { create(:learning, creator: user) }
    let(:valid_params) do
      {
        id: learning.id,
        learning: {
          lesson: 'Updated Lesson',
          description: 'Updated Description',
          public_visibility: false,
          organization_id: organization.id,
          learning_category_ids: [learning_category.id]
        }
      }
    end

    context 'with valid parameters' do
      it 'updates the learning and redirects to show with success message' do
        patch :update, params: valid_params
        learning.reload

        expect(learning.lesson).to eq('Updated Lesson')
        expect(learning.description).to eq('Updated Description')
        expect(learning.public_visibility).to be(false)
        expect(learning.organization).to eq(organization)
        expect(learning.learning_category_ids).to eq([learning_category.id])
        expect(learning.last_modifier).to eq(user)

        expect(response).to redirect_to(learning_path(learning))
        expect(flash[:success]).to eq(I18n.t('learnings.update.success', lesson: 'Updated Lesson'))
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          id: learning.id,
          learning: { lesson: '' }
        }
      end

      it 'does not update the learning and renders edit template with error message' do
        original_lesson = learning.lesson
        patch :update, params: invalid_params
        learning.reload

        expect(learning.lesson).to eq(original_lesson)
        expect(response).to render_template(:edit)
        expect(flash.now[:error]).to eq(["Lesson can't be blank"])
      end
    end

    context 'when the learning is not found' do
      it 'redirects to index with error message' do
        patch :update, params: { id: 'nonexistent', learning: { lesson: 'Updated' } }
        expect(response).to redirect_to(learnings_path)
        expect(flash[:error]).to eq(I18n.t('learnings.update.not_found'))
      end
    end
  end

  describe 'GET #cancel' do
    let(:learning) { create(:learning, creator: user) }

    context 'with Turbo Stream request' do
      it 'assigns the requested learning and renders cancel template' do
        get :cancel, params: { id: learning.id }, as: :turbo_stream

        expect(assigns(:learning)).to eq(learning)
        expect(response).to render_template(:cancel)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with HTML request' do
      it 'redirects to learning show page' do
        get :cancel, params: { id: learning.id }

        expect(response).to redirect_to(learning_path(learning))
        expect(response).to have_http_status(:see_other)
      end
    end

    context 'when the learning is not found' do
      it 'redirects to index with error message' do
        get :cancel, params: { id: 'nonexistent' }

        expect(response).to redirect_to(learnings_path)
        expect(flash[:error]).to eq(I18n.t('learnings.cancel.not_found'))
      end
    end
  end
end
