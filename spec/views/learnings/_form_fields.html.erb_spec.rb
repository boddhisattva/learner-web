# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'learnings/new.html.erb', type: :view do
  let(:organization) { build_stubbed(:organization, name: 'Test Organization') }
  let(:learning) { Learning.new }
  let(:learning_categories) { [] }

  before do
    without_partial_double_verification do
      allow(view).to receive(:current_organization).and_return(organization)
    end
    assign(:learning, learning)
    assign(:learning_categories, learning_categories)
  end

  it 'displays organization as read-only and auto-assigns current organization' do
    # Render the full template, not the partial
    render

    expect(rendered).not_to have_select('Organization')

    expect(rendered).to have_css("input[type=\"hidden\"][id=\"learning_organization_id\"][value=\"#{organization.id}\"]",
                                 visible: false)

    # Organization name should be displayed as read-only text
    expect(rendered).to have_css("input[disabled][readonly][value=\"#{organization.name}\"]")
  end
end
