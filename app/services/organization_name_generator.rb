# frozen_string_literal: true

class OrganizationNameGenerator
  def initialize(base_name)
    @base_name = base_name
  end

  def generate_unique_name
    sanitized_name = Organization.sanitize_sql_like(@base_name)
    existing_names = Organization.where('name = ? OR name LIKE ?', @base_name, "#{sanitized_name} %").pluck(:name).to_set

    return @base_name unless existing_names.include?(@base_name)

    counter = 2
    loop do
      candidate_name = "#{@base_name} #{counter}"
      return candidate_name unless existing_names.include?(candidate_name)

      counter += 1
    end
  end
end
