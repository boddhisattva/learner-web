require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  before { turbo_native_app? }

  describe '#title' do
    it 'page specific title in the context of the app name' do
      content_for(:title) { "Page Title" }

      expect(title).to eq("Page Title | #{I18n.t('learner')}")
    end

    it 'returns app name when page title is missing' do
      expect(title).to eq("#{I18n.t('learner')}")
    end

    it 'returns page specific title only for turbo native' do
      @turbo_native_app = true

      expect(title).to eq("#{I18n.t('learner')}")
    end
  end

  def turbo_native_app?
    @turbo_native_app = false
  end
end
