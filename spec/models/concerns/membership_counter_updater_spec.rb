# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MembershipCounterUpdater do
  let(:test_class) { Learning }

  describe 'counter cache updates' do
    let(:user) { create(:user, :with_organization_and_membership) }
    let(:organization) { user.personal_organization }
    let(:membership) { Membership.find_by(member: user, organization: organization) }

    context 'on create' do
      it 'increments membership counter by 1' do
        expect do
          create(:learning, creator: user, organization: organization)
        end.to change { membership.reload.learnings_count }.by(1)
      end
    end

    context 'on destroy' do
      it 'decrements membership counter by 1' do
        learning = create(:learning, creator: user, organization: organization)

        expect do
          learning.destroy
        end.to change { membership.reload.learnings_count }.by(-1)
      end
    end

    context 'on restore (paranoia)' do
      it 'increments membership counter by 1' do
        learning = create(:learning, creator: user, organization: organization)
        learning.destroy

        expect do
          learning.restore
        end.to change { membership.reload.learnings_count }.by(1)
      end
    end

    context 'on real_destroy (paranoia)' do
      it 'does not decrement counter when destroying already soft-deleted record' do
        learning = create(:learning, creator: user, organization: organization)
        # Soft-delete first (counter already decremented)
        learning.destroy
        initial_count = membership.reload.learnings_count

        expect do
          learning.really_destroy!
        end.not_to change { membership.reload.learnings_count }.from(initial_count)
      end

      it 'decrements counter only once when really_destroy! called on non-deleted record' do
        learning = create(:learning, creator: user, organization: organization)
        initial_count = membership.reload.learnings_count

        expect do
          learning.really_destroy!
        end.to change { membership.reload.learnings_count }.from(initial_count).to(initial_count - 1)
      end
    end

    context 'when membership does not exist' do
      it 'does not raise error on create' do
        user_without_membership = create(:user)
        organization_without_membership = create(:organization)

        expect do
          create(:learning, creator: user_without_membership, organization: organization_without_membership)
        end.not_to raise_error
      end

      it 'does not raise error on destroy' do
        user_without_membership = create(:user)
        organization_without_membership = create(:organization)
        learning = create(:learning, creator: user_without_membership, organization: organization_without_membership)

        expect do
          learning.destroy
        end.not_to raise_error
      end
    end

    context 'with multiple learnings' do
      it 'maintains correct count across multiple operations' do
        learning1 = create(:learning, creator: user, organization: organization)
        learning2 = create(:learning, creator: user, organization: organization)
        expect(membership.reload.learnings_count).to eq(2)

        learning1.destroy
        expect(membership.reload.learnings_count).to eq(1)

        learning1.restore
        expect(membership.reload.learnings_count).to eq(2)

        learning1.destroy
        learning2.destroy
        expect(membership.reload.learnings_count).to eq(0)
      end
    end
  end
end
