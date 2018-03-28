# frozen_string_literal: true

require 'test_helper'
require 'support/services/invoice/recipient_loader_support'

describe Invoice::RecipientLoader do
  describe '#call' do
    let!(:invoice) { create(:invoice) }

    before do
      AfipMock.mock_login
      PeopleServiceMock.mock(:ws_wsdl)
      InvoicesServiceMock.mock(:ws_wsdl)
    end

    subject { described_class.new(invoice) }

    context 'when person is loaded from external service' do
      shared_examples "invoice's recipient loader" do
        let!(:people_mock) do
          PeopleServiceMock.mock(:natural_responsible_person)
        end

        it 'loads recipient into invoice' do
          expect { subject.call(cuit) }
            .to change { invoice.recipient }
            .from(nil)

          expect(invoice.recipient)
            .to match_valid_format(Invoice::RecipientLoaderSupport::RECIPIENT_FORMAT)

          expect(invoice.recipient.symbolize_keys).to eq({
            address: 'SAN MARTIN 8',
            category: 'Responsable inscripto',
            city: 'ALTO DE LA LOMA',
            full_address: 'SAN MARTIN 8 ALTO DE LA LOMA, JUJUY ',
            name: 'MARTINCHUS RAZONAR',
            state: 'JUJUY',
            zipcode: '4500',
          })
        end

        it 'fetches recipient information from external service' do
          subject.call(cuit)

          expect(people_mock).to have_been_requested
        end
      end

      context 'when CUIT is received' do
        let(:cuit) { Faker::Number.number(digits: 10) }

        it_behaves_like "invoice's recipient loader"
      end

      context 'when CUIT is not received' do
        let(:cuit) { nil }
        let!(:invoice_mock) { InvoicesServiceMock.mock(:invoice) }

        context 'and invoice can be fetched from external service' do
          it_behaves_like "invoice's recipient loader"

          it 'fetches invoice information from external service' do
            PeopleServiceMock.mock(:natural_responsible_person)

            subject.call

            expect(invoice_mock).to have_been_requested
          end
        end

        context 'and invoice cannot be fetched from external service' do
          before do
            InvoicesServiceMock.mock(:invoice_not_found)
          end

          it 'does not load recipient into invoice' do
            expect { subject.call }
              .not_to change { invoice.recipient }
              .from(nil)
          end

          context 'and invoice already has a recipient' do
            before do
              invoice.update(recipient: { anything: 123 })
            end

            it "does not change existing invoice's recipient" do
              expect { subject.call }
                .not_to change { invoice.recipient }
                .from({ 'anything' => 123 })
            end
          end
        end
      end
    end

    context 'when an error is raised while fetching person from AFIP' do
      before do
        InvoicesServiceMock.mock(:invoice)
        PeopleServiceMock.mock(:natural_responsible_person)

        expect_any_instance_of(Afip::Person)
          .to receive(:info)
          .and_raise(StandardError)
      end

      it 'returns false' do
        expect(subject.call).to be false
      end
    end
  end
end
