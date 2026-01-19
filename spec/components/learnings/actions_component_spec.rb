# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Learnings::ActionsComponent, type: :component do
  let(:user) { create(:user, :with_organization_and_membership) }
  let(:organization) { user.personal_organization }
  let(:learning) { create(:learning, creator: user, organization: organization) }

  describe '#render' do
    it 'renders all action buttons with correct links, turbo behavior, and icons' do
      rendered = render_inline(described_class.new(learning: learning))

      view_link = rendered.css('a.button.is-info').first
      expect(view_link['href']).to eq(learning_path(learning))
      expect(view_link['data-turbo']).to eq('false')
      expect(rendered.css('a.button.is-info i.fa-eye')).to be_present

      edit_link = rendered.css('a.button.is-warning').first
      expect(edit_link['href']).to eq(edit_learning_path(learning))
      expect(edit_link['data-turbo-frame']).to eq(dom_id(learning))
      expect(rendered.css('a.button.is-warning i.fa-edit')).to be_present

      delete_link = rendered.css('a.button.is-danger').first
      expect(delete_link['href']).to eq(learning_path(learning))
      expect(delete_link['data-turbo-method']).to eq('delete')
      expect(delete_link['data-turbo-confirm']).to eq('Are you sure?')
      expect(rendered.css('a.button.is-danger i.fa-trash')).to be_present
    end
  end
end
