# frozen_string_literal: true

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

      # TO DO: # Add spec with regards to null organization edge case as well and take things from there
      it 'creates a new user, organisation with user name, membership & redirects to one\'s feed after successful sign up' do
        expect do
          post :create, params: valid_attributes
        end.to change(User, :count).by(1)
           .and change(Organization, :count).by(1)
           .and change(Membership, :count).by(1)

        expect(response).to have_http_status(:see_other)

        newly_created_user = User.first

        expect(Organization.first.name).to eq(newly_created_user.name)
        expect(newly_created_user.email).to eq('jim.weirich@test.com')
        expect(newly_created_user.first_name).to eq('Jim')
        expect(newly_created_user.last_name).to eq('Weirich')

        expect(response).to redirect_to('/learnings/index')

        expect(flash[:success]).to eq(I18n.t('users.create.welcome', name: 'Jim Weirich'))
      end
    end

    # TODO: If needed, Look into adding a test case if organization name update fails
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
        # rubocop:disable RSpec / ChangeByZero
        expect do
          post :create, params: invalid_attributes
        end.to change(User, :count).by(0)
           .and change(Organization, :count).by(0)
           .and change(Membership, :count).by(0)
        # rubocop:enable RSpec / ChangeByZero

        expect(response).to have_http_status(:unprocessable_entity)

        expect(response).to render_template('devise/registrations/new')

        expect(flash[:error].first)
          .to eq("Password #{I18n.t('activerecord.errors.models.user.attributes.password.too_short')}")

      end
    end
  end

  describe '#update' do
    let(:user)         { create(:user, first_name: '  Rachel ', last_name: ' Longwood', email: '  rachel@xyz.com ') }
    let(:organization) { create(:organization, name: user.name)                                                     }

    before do
      sign_in user
      # Whenever a new user is created via user sign up flow, an organization is created with user name, hence adding relevant setup
      organization
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

      it 'updates a user details, organisation name accordingly if needed and returns related success message' do
        expect(organization.name).to eq('Rachel Longwood')

        patch :update, params: valid_attributes

        expect(user.reload.last_name).to eq('Peters')
        expect(organization.reload.name).to eq('Rachel Peters')
        expect(user.email).to eq('rachel.peters@xyz.com')
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(profile_path)
        expect(flash[:success]).to eq(I18n.t('users.update.success'))
      end
    end

    context 'when organization with same name already exists' do
      let(:other_user) { create(:user, first_name: '  Marcus ', last_name: ' Aurelius', email: 'marcus@xyz.com ') }
      let(:other_organization) { create(:organization, name: other_user.name) }
      let(:user_attributes) do
        {
          user: {
            first_name: user.first_name,
            last_name: user.last_name
          }
        }
      end

      before do
        sign_in other_user
        other_organization
      end

      # rubocop:disable Layout/LineLength
      it 'raises an appropriate error and does not update the other organization with the new name' do
        patch(:update, params: user_attributes)

        expect(response).to render_template(:edit)
        expect(flash[:error]).to include(match(/Name PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint "index_organizations_on_name"/))
      end
    end
    # rubocop:enable Layout/LineLength

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
