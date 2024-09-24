require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  describe '#title' do
    it 'page specific title in the context of the app name' do
      content_for(:title) { "Page Title" }

      expect(title).to eq("Page Title | #{I18n.t('learner')}")
    end

    it 'returns app name when page title is missing' do
      expect(title).to eq("#{I18n.t('learner')}")
    end
  end
end
