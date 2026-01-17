# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRegistration do
  describe '#call' do
    let(:user) do
      User.new(
        first_name: 'Jim',
        last_name: 'Weirich',
        email: 'jim.weirich@test.com',
        password: 'tester768'
      )
    end

    context 'with valid user attributes' do

      it 'creates user, organization, membership and returns true' do
        expect do
          result = described_class.new(user).call
          expect(result).to be true
        end.to change(User, :count).by(1)
           .and change(Organization, :count).by(1)
           .and change(Membership, :count).by(1)

        user.reload
        expect(user.personal_organization).to be_present
        expect(user.personal_organization.name).to eq('Jim Weirich')
        expect(user.personal_organization.owner).to eq(user)
        expect(user.memberships.count).to eq(1)
        expect(user.organizations).to include(user.personal_organization)
      end

      context 'when organization name already exists' do
        before do
          existing_user = User.create!(
            first_name: 'Jim',
            last_name: 'Weirich',
            email: 'jim.existing@test.com',
            password: 'password123'
          )
          organization = Organization.create!(name: 'Jim Weirich', owner: existing_user)
          existing_user.update!(personal_organization: organization)
          Membership.create!(member: existing_user, organization: organization)
        end

        it 'creates organization with unique name using sequential number suffix' do
          expect do
            result = described_class.new(user).call
            expect(result).to be true
          end.to change(User, :count).by(1)
             .and change(Organization, :count).by(1)
             .and change(Membership, :count).by(1)

          user.reload
          expect(user.personal_organization).to be_present
          expect(user.personal_organization.name).to eq('Jim Weirich 2')
        end
      end
    end

    context 'with invalid user attributes' do
      let(:user) do
        User.new(
          first_name: 'Jim',
          last_name: 'Weirich',
          email: 'jim.weirich@test.com',
          password: 'shortpw'
        )
      end

      it 'does not create user, organization, or membership and returns false' do
        expect do
          result = described_class.new(user).call
          expect(result).to be false
        end.to change(User, :count).by(0)
           .and change(Organization, :count).by(0)
           .and change(Membership, :count).by(0)

        expect(user.errors[:password]).to be_present
        expect(user.errors.full_messages).to include("Password #{I18n.t('activerecord.errors.models.user.attributes.password.too_short')}")
      end
    end

    context 'when organization creation fails' do
      before do
        allow(Organization).to receive(:create!).and_raise(
          ActiveRecord::RecordInvalid.new(Organization.new)
        )
      end

      it 'rolls back user creation, adds error to user, and returns false' do
        expect do
          result = described_class.new(user).call
          expect(result).to be false
        end.to change(User, :count).by(0)
           .and change(Organization, :count).by(0)
           .and change(Membership, :count).by(0)

        expect(user.errors[:base]).to be_present
        expect(user.errors[:base].first).to include('Organization failed:')
      end
    end

    context 'when membership creation fails' do
      before do
        allow(Membership).to receive(:create!).and_raise(
          ActiveRecord::RecordInvalid.new(Membership.new)
        )
      end

      it 'rolls back all changes and returns false' do
        expect do
          result = described_class.new(user).call
          expect(result).to be false
        end.to change(User, :count).by(0)
           .and change(Organization, :count).by(0)
           .and change(Membership, :count).by(0)
      end
    end
  end
end
