require 'rails_helper'

RSpec.describe UsersController, type: :controller do

  describe '#create' do

    context 'with valid user attributes' do
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

      it 'creates a new user, organisation & redirects to one\'s feed after successful sign up' do
        expect do
          post :create, params: valid_attributes
        end.to change { User.count }.by(1)
           .and change { Organization.count }.by(1)

        expect(response).to have_http_status(:see_other)

        expect(response).to redirect_to('/feed')

        expect(flash[:success]).to eq(I18n.t("users.create.welcome", name: 'Jim Weirich'))
      end
    end

    context 'with one or more invalid user attributes' do
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

      it 'renders errors if input data is invalid and no new users and organisations are created' do
        expect do
          post :create, params: invalid_attributes
        end.to change { User.count }.by(0)
           .and change { Organization.count }.by(0)

        expect(response).to have_http_status(:unprocessable_entity)

        expect(response).to render_template('devise/registrations/new')

        expect(flash[:error].first)
          .to eq("Password #{I18n.t ('activerecord.errors.models.user.attributes.password.too_short')}")

      end
    end
  end
end
