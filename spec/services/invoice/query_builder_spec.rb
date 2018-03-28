# frozen_string_literal: true

require 'test_helper'
require 'support/services/invoice/query_builder_support'

describe Invoice::QueryBuilder do
  describe '#call' do
    shared_examples 'valid response format' do
      it 'returns a hash with a valid format' do
        response = subject.call[Invoice::QueryBuilderSupport::RESPONSE_MASTER_KEY]
        header = response[Invoice::QueryBuilderSupport::RESPONSE_HEADER_KEY]
        body = response[Invoice::QueryBuilderSupport::RESPONSE_BODY_KEY]
        body_content = body[Invoice::QueryBuilderSupport::RESPONSE_BODY_CONTENT_KEY]

        expect(response)
          .to match_valid_format(Invoice::QueryBuilderSupport::RESPONSE_FORMAT)

        expect(header)
          .to match_valid_format(Invoice::QueryBuilderSupport::RESPONSE_HEADER_FORMAT)

        expect(body)
          .to match_valid_format(Invoice::QueryBuilderSupport::RESPONSE_BODY_FORMAT)

        expect(body_content)
          .to match_valid_format(Invoice::QueryBuilderSupport::RESPONSE_BODY_CONTENT_FORMAT)

        iva_items = body_content[Invoice::QueryBuilderSupport::IVA_KEY][Invoice::QueryBuilderSupport::IVA_CONTENT_KEY]

        expect(iva_items).not_to be_empty

        iva_items.each do |item|
          expect(item)
            .to match_valid_format(Invoice::QueryBuilderSupport::IVA_CONTENT_FORMAT)
        end

        taxes_items = body_content[Invoice::QueryBuilderSupport::TAXES_KEY][Invoice::QueryBuilderSupport::TAXES_CONTENT_KEY]

        expect(taxes_items).not_to be_empty

        taxes_items.each do |item|
          expect(item)
            .to match_valid_format(Invoice::QueryBuilderSupport::TAXES_CONTENT_FORMAT)
        end
      end
    end

    let(:attributes) { Invoice::QueryBuilderSupport::QUERY }

    subject do
      described_class.new(attributes)
    end

    it_behaves_like 'valid response format'

    context 'when optional parameters are received' do
      shared_examples 'valid response format with optional parameters' do
        it 'returns a hash including a valid format for optional parameters' do
          optional_items = fetch_optional_parameters(subject.call)

          expect(optional_items).not_to be_empty

          optional_items.each do |item|
            expect(item)
              .to match_valid_format(Invoice::QueryBuilderSupport::OPT_CONTENT_FORMAT)
          end
        end
      end

      shared_examples 'valid response format with specific optional parameter' do |id, value|
        it 'returns a hash including CBU as optional parameter' do
          optional_items = fetch_optional_parameters(subject.call)

          expect(optional_items)
            .to include({ 'Id' => id, 'Valor' => value })
        end
      end

      context 'and invoice is an electronic credit invoice' do
        Invoice::Schema::ELECTRONIC_CREDIT_INVOICES_IDS.each do |id|
          context "and bill_type_id is #{id}" do
            let(:attributes) do
              Invoice::QueryBuilderSupport::QUERY
                .merge(Invoice::QueryBuilderSupport::OPT_ATTRIBUTES)
                .merge(bill_type_id: id)
            end

            it_behaves_like 'valid response format with optional parameters'
            it_behaves_like 'valid response format with specific optional parameter',
              '2101',
              Invoice::QueryBuilderSupport::OPT_ATTRIBUTES[:cbu]

            it_behaves_like 'valid response format with specific optional parameter',
              '2102',
              Invoice::QueryBuilderSupport::OPT_ATTRIBUTES[:alias]

            it_behaves_like 'valid response format with specific optional parameter',
              '27',
              Invoice::QueryBuilderSupport::OPT_ATTRIBUTES[:transmission]
          end
        end
      end

      context 'and invoice is an electronic note' do
        Invoice::Schema::ELECTRONIC_NOTES_IDS.each do |id|
          let(:attributes) do
            query = Invoice::QueryBuilderSupport::QUERY
              .merge(Invoice::QueryBuilderSupport::OPT_ATTRIBUTES)
              .merge(bill_type_id: id)

            query[:associated_invoices] << Invoice::QueryBuilderSupport::ASSOCIATED_INVOICE.dup

            query
          end

          context 'and it has rejected associated invoices' do
            before do
              attributes[:associated_invoices].first[:rejected] = true
            end

            it_behaves_like 'valid response format with optional parameters'

            it_behaves_like 'valid response format with specific optional parameter', '22', 'S'
          end

          context 'and it has rejected associated invoices' do
            before do
              attributes[:associated_invoices].first[:rejected] = false
            end

            it_behaves_like 'valid response format with optional parameters'

            it_behaves_like 'valid response format with specific optional parameter', '22', 'N'
          end
        end
      end
    end
  end

  private

  def fetch_optional_parameters(response)
    response[Invoice::QueryBuilderSupport::RESPONSE_MASTER_KEY][Invoice::QueryBuilderSupport::RESPONSE_BODY_KEY][Invoice::QueryBuilderSupport::RESPONSE_BODY_CONTENT_KEY][Invoice::QueryBuilderSupport::OPT_KEY][Invoice::QueryBuilderSupport::OPT_CONTENT_KEY]
  end
end
