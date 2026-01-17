# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe '#create' do
    let(:valid_attributes) do
      {
        user: {
          first_name: 'Jim',
          last_name: 'Weirich',
          email: 'jim.weirich@test.com',
          password: 'tester768'
        }
      }
    end
    let(:invalid_attributes) do
      {
        user: {
          first_name: 'Jim',
          last_name: 'Weirich',
          email: 'jim.weirich@test.com',
          password: 'test'
        }
      }
    end
    let(:service) { instance_double(UserRegistration) }

    context 'when service succeeds' do
      it 'signs in user, redirects to learnings path with success message' do
        allow(UserRegistration).to receive(:new).and_return(service)
        allow(service).to receive(:call).and_return(true)

        post :create, params: valid_attributes

        expect(UserRegistration).to have_received(:new)
        expect(service).to have_received(:call)
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to('/learnings')
        expect(flash[:success]).to eq(I18n.t('users.create.welcome', name: 'Jim Weirich'))
      end
    end

    context 'when service fails' do
      it 'renders new template with unprocessable entity status' do
        allow(UserRegistration).to receive(:new).and_return(service)
        allow(service).to receive(:call).and_return(false)

        post :create, params: invalid_attributes

        expect(UserRegistration).to have_received(:new)
        expect(service).to have_received(:call)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('devise/registrations/new')
      end
    end

    context 'when service raises an exception' do
      let(:error_message) { 'Something went wrong' }

      it 'logs error, renders new template with error message and unprocessable entity status' do
        allow(UserRegistration).to receive(:new).and_return(service)
        allow(service).to receive(:call).and_raise(StandardError.new(error_message))

        post :create, params: valid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template('devise/registrations/new')
        expect(flash[:error]).to eq(["Error: #{error_message}. Please try again."])
      end
    end
  end

  describe '#update' do
    let(:user) do
      create(:user, :with_organization_and_membership, first_name: '  Rachel ', last_name: ' Longwood', email: '  rachel@xyz.com ')
    end
    let(:organization) { user.personal_organization }

    before do
      sign_in user
    end

    context 'with valid user attributes' do
      let(:valid_attributes) do
        {
          user: {
            last_name: 'Peters',
            email: 'rachel.peters@xyz.com'
          }
        }
      end

      it 'updates user details and returns success message' do
        patch :update, params: valid_attributes

        expect(user.reload.last_name).to eq('Peters')
        expect(user.email).to eq('rachel.peters@xyz.com')
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(profile_path)
        expect(flash[:success]).to eq(I18n.t('users.update.success'))
      end
    end

    context 'with invalid user attributes' do
      let(:invalid_attributes) do
        {
          user: {
            last_name: '',
            email: 'rachel.peters@xyz.com'
          }
        }
      end

      it 'returns one or more errors related to a failed user update' do
        patch :update, params: invalid_attributes

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
        expect(flash[:error].first)
          .to eq("Last name can't be blank")
      end
    end
  end
end
