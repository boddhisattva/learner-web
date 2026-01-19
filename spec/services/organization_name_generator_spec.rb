# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationNameGenerator do
  describe '#generate_unique_name' do
    context 'when organization name is unique' do
      it 'returns the base name without suffix' do
        generator = described_class.new('John Smith')

        expect(generator.generate_unique_name).to eq('John Smith')
      end
    end

    context 'when organization name already exists' do
      before do
        create(:organization, name: 'John Smith')
      end

      it 'returns name with sequential number suffix' do
        generator = described_class.new('John Smith')

        expect(generator.generate_unique_name).to eq('John Smith 2')
      end

      context 'when multiple duplicates exist' do
        before do
          create(:organization, name: 'John Smith 2')
          create(:organization, name: 'John Smith 3')
        end

        it 'continues finding next available sequential number' do
          generator = described_class.new('John Smith')

          expect(generator.generate_unique_name).to eq('John Smith 4')
        end
      end
    end

    context 'when base name contains special characters' do
      it 'handles names with special characters correctly' do
        generator = described_class.new("O'Brien & Associates")

        expect(generator.generate_unique_name).to eq("O'Brien & Associates")
      end

      context 'when base name contains other special characters and SQL LIKE wildcard characters' do
        it 'sanitizes wildcard characters and handles them correctly' do
          generator = described_class.new("O'Brien & Associates Company_%Name")

          expect(generator.generate_unique_name).to eq("O'Brien & Associates Company_%Name")
        end

        context 'when name with wildcard characters already exists' do
          before do
            create(:organization, name: "O'Brien & Associates Company_%Name")
          end

          it 'sanitizes wildcard characters and generates unique name with suffix' do
            generator = described_class.new("O'Brien & Associates Company_%Name")

            expect(generator.generate_unique_name).to eq("O'Brien & Associates Company_%Name 2")
          end

          context 'when multiple duplicates with wildcard characters exist' do
            before do
              create(:organization, name: "O'Brien & Associates Company_%Name 2")
              create(:organization, name: "O'Brien & Associates Company_%Name 3")
            end

            it 'continues finding next available sequential number' do
              generator = described_class.new("O'Brien & Associates Company_%Name")

              expect(generator.generate_unique_name).to eq("O'Brien & Associates Company_%Name 4")
            end
          end
        end
      end
    end

    context 'when base name is empty' do
      it 'returns empty string' do
        generator = described_class.new('')

        expect(generator.generate_unique_name).to eq('')
      end
    end
  end
end
