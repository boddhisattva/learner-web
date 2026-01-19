# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'learnings/_empty_state.html.erb', type: :view do
  context 'when no learnings exist' do
    it 'shows empty state message with create link' do
      render partial: 'learnings/empty_state', locals: { query: nil }

      expect(rendered).to have_content('No learnings have been created yet')
      expect(rendered).to have_link('Create your first learning', href: new_learning_path)
      expect(rendered).not_to have_content('No learnings found matching')
    end
  end
end
