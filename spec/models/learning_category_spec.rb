# frozen_string_literal: true

# == Schema Information
#
# Table name: learning_categories
#
#  id                                                             :bigint           not null, primary key
#  deleted_at                                                     :datetime
#  description(More information about the learning category)      :text
#  name(Name of the learning category)                            :string           not null
#  created_at                                                     :datetime         not null
#  updated_at                                                     :datetime         not null
#  creator_id(User who created the learning category)             :bigint           not null
#  last_modifier_id(User who last modified the learning category) :bigint           not null
#
# Indexes
#
#  index_learning_categories_on_creator_id        (creator_id)
#  index_learning_categories_on_deleted_at        (deleted_at)
#  index_learning_categories_on_last_modifier_id  (last_modifier_id)
#  index_learning_categories_on_name              (name) UNIQUE WHERE (deleted_at IS NULL)
#
# Foreign Keys
#
#  fk_rails_...  (creator_id => users.id)
#  fk_rails_...  (last_modifier_id => users.id)
#

require 'rails_helper'

RSpec.describe LearningCategory, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:creator).class_name('User') }
    it { is_expected.to belong_to(:last_modifier).class_name('User') }
  end

end
