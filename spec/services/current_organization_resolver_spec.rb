# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CurrentOrganizationResolver do
  let(:user) { create(:user, :with_organization_and_membership) }
  let(:personal_organization) { user.personal_organization }
  let(:session) { {} }

  describe '#resolve' do
    context 'when user is nil' do
      it 'returns nil' do
        resolver = described_class.new(nil, session)

        expect(resolver.resolve).to be_nil
      end
    end

    context 'when session has current_organization_id' do
      context 'when organization exists and user has access via membership' do
        let(:other_organization) { create(:organization, owner: create(:user)) }
        let(:session) { { current_organization_id: other_organization.id } }

        before do
          create(:membership, member: user, organization: other_organization)
        end

        it 'returns the organization from session' do
          resolver = described_class.new(user, session)

          expect(resolver.resolve).to eq(other_organization)
        end
      end

      context 'when organization does not exist' do
        let(:session) { { current_organization_id: 999_999 } }

        it 'falls back to personal organization' do
          resolver = described_class.new(user, session)

          expect(resolver.resolve).to eq(personal_organization)
        end
      end

      context 'when user does not have access to organization' do
        let(:other_organization) { create(:organization, owner: create(:user)) }
        let(:session) { { current_organization_id: other_organization.id } }

        it 'falls back to personal organization' do
          resolver = described_class.new(user, session)

          expect(resolver.resolve).to eq(personal_organization)
        end
      end

      context 'when session has multiple organizations and user belongs to all' do
        let(:org1) { create(:organization, owner: create(:user)) }
        let(:org2) { create(:organization, owner: create(:user)) }
        let(:session) { { current_organization_id: org1.id } }

        before do
          create(:membership, member: user, organization: org1)
          create(:membership, member: user, organization: org2)
        end

        it 'returns the organization specified in session' do
          resolver = described_class.new(user, session)

          expect(resolver.resolve).to eq(org1)
        end
      end
    end

    context 'when session does not have current_organization_id' do
      it 'returns personal organization' do
        resolver = described_class.new(user, session)

        expect(resolver.resolve).to eq(personal_organization)
      end
    end

    context 'when session has nil current_organization_id' do
      let(:session) { { current_organization_id: nil } }

      it 'returns personal organization' do
        resolver = described_class.new(user, session)

        expect(resolver.resolve).to eq(personal_organization)
      end
    end

    context 'when session has empty string as current_organization_id' do
      let(:session) { { current_organization_id: '' } }

      it 'returns personal organization' do
        resolver = described_class.new(user, session)

        expect(resolver.resolve).to eq(personal_organization)
      end
    end

    context 'when user has no personal organization' do
      let(:user_without_org) { create(:user) }

      it 'returns nil' do
        resolver = described_class.new(user_without_org, session)

        expect(resolver.resolve).to be_nil
      end

      context 'when session has valid organization ID but user has no personal org' do
        let(:other_organization) { create(:organization, owner: create(:user)) }
        let(:session) { { current_organization_id: other_organization.id } }

        before do
          create(:membership, member: user_without_org, organization: other_organization)
        end

        it 'returns the organization from session' do
          resolver = described_class.new(user_without_org, session)

          expect(resolver.resolve).to eq(other_organization)
        end
      end
    end
  end
end
