# frozen_string_literal: true

RSpec.shared_context 'with learning owner and other user' do
  let(:alice) { create(:user, :with_organization_and_membership) }
  let(:bob) { create(:user) }
  let(:alice_learning) { create(:learning, creator: alice) }
end
