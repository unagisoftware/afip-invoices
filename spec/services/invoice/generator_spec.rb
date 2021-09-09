# frozen_string_literal: true

require 'test_helper'
require 'support/services/invoice/finder_support'
require 'support/services/invoice/generator_support'

describe Invoice::Generator do
  let(:entity) { create(:entity) }

  before do
    AfipMock.mock_login
    InvoicesServiceMock.mock(:ws_wsdl)
    PeopleServiceMock.mock(:ws_wsdl)
  end

  describe '#call' do
    shared_examples 'invoice response' do |format|
      it 'returns the created invoice' do
        result = subject.call

        expect(result.represented_invoice)
          .to match_valid_representer_format(format || Invoice::GeneratorSupport::CREATED_INVOICE_FORMAT)
      end
    end

    shared_examples 'invoice persistance' do |receipt_number|
      it 'persists the invoice' do
        invoice_params = build_invoice_params

        expect { subject.call }.to change { Invoice.count }.by(1)

        invoice = Invoice.last

        expect(invoice).to have_attributes(
          alias: invoice_params[:alias],
          bill_type_id: invoice_params[:bill_type_id].to_i,
          cbu: invoice_params[:cbu],
          emission_date: invoice_params[:created_at].to_date,
          logo_url: invoice.entity.logo.to_s,
          note: invoice_params[:note],
          receipt: receipt_number,
          sale_point_id: invoice_params[:sale_point_id],
        )
      end
    end

    shared_examples 'invoice persistance failure' do
      it 'does not persists the invoice' do
        expect { subject.call }.not_to change { Invoice.count }
      end
    end

    shared_examples 'AFIP invoice creation' do
      it 'creates the invoice in AFIP' do
        subject.call

        expect(InvoicesServiceMock.mock(:create_invoice))
          .to have_been_requested
      end

      it 'does not return errors' do
        expect(subject.call.with_errors?).to be false
      end
    end

    shared_examples 'AFIP invoice creation failure' do
      it 'does not creates the invoice in AFIP' do
        subject.call

        expect(InvoicesServiceMock.mock(:create_invoice_error))
          .to have_been_requested
      end

      it 'returns errors' do
        expect(subject.call.with_errors?).to be true
      end
    end

    shared_examples 'AFIP request deletion' do
      it 'deletes the existing AFIP request' do
        expect { subject.call }.to change { AfipRequest.count }.by(-1)
      end
    end

    context 'when invoice was created in AFIP' do
      context 'and it is persisted' do
        let!(:invoice_params) { build_invoice_params }
        let!(:invoice) do
          create(
            :invoice,
            bill_type_id: invoice_params[:bill_type_id],
            receipt: invoice_params[:recipient_number],
          )
        end

        before do
          mock_invoice_finder_with(response: nil)
        end

        subject do
          described_class.new(
            invoice_params,
            entity,
            build_invoice_id_client_params,
          )
        end

        it_behaves_like 'invoice response'

        it "returns an 'existing' status for the invoice" do
          result = subject.call

          expect(result.status).to eq(:existing)
        end

        it 'does not create any AFIP request' do
          expect { subject.call }.not_to change { AfipRequest.count }
        end
      end

      context 'and it is not persisted but it was previously enqueued' do
        let!(:invoice_id_client) { Faker::Number.number(digits: 2) }

        let!(:afip_request) do
          create(:afip_request, invoice_id_client: invoice_id_client)
        end

        before do
          InvoicesServiceMock.mock(:invoice)
          PeopleServiceMock.mock(:legal_person)
        end

        before do
          mock_invoice_finder_with(response: Invoice::FinderSupport::RESPONSE)
        end

        subject do
          described_class.new(
            build_invoice_params,
            entity,
            build_invoice_id_client_params(invoice_id_client),
          )
        end

        it_behaves_like 'invoice response'
        it_behaves_like 'AFIP request deletion'

        it_behaves_like 'invoice persistance',
          Invoice::FinderSupport::RESPONSE[:bill_number]

        it "returns a 'created' status for the invoice" do
          result = subject.call

          expect(result.status).to eq(:created)
        end
      end
    end

    context 'when invoice was not created in AFIP' do
      context 'and it is not persisted but it was previously enqueued' do
        let!(:invoice_id_client) { Faker::Number.number(digits: 2) }

        let!(:afip_request) do
          create(:afip_request, invoice_id_client: invoice_id_client)
        end

        let!(:last_bill_number_mock) do
          InvoicesServiceMock.mock(:last_bill_number)
        end

        before do
          InvoicesServiceMock.mock(:invoice_not_found)
          PeopleServiceMock.mock(:legal_person)
          mock_invoice_finder_with(response: nil)
        end

        subject do
          described_class.new(
            build_invoice_params,
            entity,
            build_invoice_id_client_params(invoice_id_client),
          )
        end

        context 'and AFIP connection is successful' do
          before do
            InvoicesServiceMock.mock(:create_invoice)
          end

          it_behaves_like 'invoice response'
          it_behaves_like 'AFIP invoice creation'
          it_behaves_like 'AFIP request deletion'

          it_behaves_like 'invoice persistance',
            Invoice::GeneratorSupport.next_bill_number

          it "returns a 'created' status for the invoice" do
            result = subject.call

            expect(result.status).to eq(:created)
          end

          it 'requests last bill number only once' do
            subject.call

            expect(last_bill_number_mock).to have_been_requested.times(1)
          end
        end

        context 'and AFIP connection fails' do
          before do
            InvoicesServiceMock.mock(:create_invoice_error)
          end

          it_behaves_like 'invoice response',
            Invoice::GeneratorSupport::DEFAULT_INVOICE_FORMAT

          it_behaves_like 'invoice persistance failure'
          it_behaves_like 'AFIP invoice creation failure'

          it "returns a 'in_progress' status for the invoice" do
            result = subject.call

            expect(result.status).to eq(:in_progress)
          end
        end

        context 'and invoice creation fails' do
          let(:error) { StandardError.new('error message') }

          before do
            InvoicesServiceMock.mock(:create_invoice)

            expect_any_instance_of(Invoice::Creator)
              .to receive(:call)
              .and_raise(error)
          end

          it 'creates logs entry' do
            expect_any_instance_of(Loggers::Invoice)
              .to receive(:error)
              .with(hash_including(message: error))
              .and_call_original

            expect { subject.call }.to raise_error(error)
          end
        end
      end

      context 'and it is not persisted nor previously enqueued' do
        let!(:last_bill_number_mock) do
          InvoicesServiceMock.mock(:last_bill_number)
        end

        before do
          InvoicesServiceMock.mock(:create_invoice)
          PeopleServiceMock.mock(:legal_person)

          mock_invoice_finder_with(response: nil)
        end

        subject do
          described_class.new(
            build_invoice_params,
            entity,
            build_invoice_id_client_params,
          )
        end

        context 'and AFIP connection is successful' do
          before do
            InvoicesServiceMock.mock(:create_invoice)
          end

          it_behaves_like 'invoice response'
          it_behaves_like 'AFIP invoice creation'

          it_behaves_like 'invoice persistance',
            Invoice::GeneratorSupport.next_bill_number

          it "returns a 'created' status for the invoice" do
            result = subject.call

            expect(result.status).to eq(:created)
          end

          it 'requests last bill number only once' do
            subject.call

            expect(last_bill_number_mock).to have_been_requested.once
          end
        end

        context 'and AFIP connection fails' do
          before do
            InvoicesServiceMock.mock(:create_invoice_error)
          end

          it_behaves_like 'invoice response',
            Invoice::GeneratorSupport::DEFAULT_INVOICE_FORMAT

          it_behaves_like 'invoice persistance failure'
          it_behaves_like 'AFIP invoice creation failure'

          it "returns a 'in_progress' status for the invoice" do
            result = subject.call

            expect(result.status).to eq(:in_progress)
          end
        end
      end
    end
  end

  private

  def mock_invoice_finder_with(response:)
    invoice_finder_double = instance_double(Invoice::Finder)

    allow(invoice_finder_double).to receive(:run).and_return(response)
    allow(Invoice::Finder).to receive(:new).and_return(invoice_finder_double)
  end

  def build_invoice_params
    Invoice::GeneratorSupport::PARAMS.dup
  end

  def build_invoice_id_client_params(external_id = nil)
    { external_id: external_id || Faker::Number.number(digits: 2) }
  end
end
