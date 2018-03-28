# frozen_string_literal: true

require 'test_helper'
require 'support/services/invoice/validator_support'

describe Invoice::Validator do
  describe '#call' do
    shared_examples 'no errors response' do
      it 'returns no errors' do
        expect(subject.call).to be_empty
      end
    end

    shared_examples 'errors response' do |error|
      it 'returns errors' do
        validation = subject.call

        expect(validation).not_to be_empty
        expect(validation).to include(error) if error
      end
    end

    let(:attributes) { Invoice::ValidatorSupport::QUERY.dup }

    subject { described_class.new(attributes) }

    context 'when a valid query is received' do
      Invoice::Schema::CONCEPTS.each_value do |concept|
        context "and it has #{concept} concept" do
          let(:attributes) do
            Invoice::ValidatorSupport::QUERY.merge(concept_type_id: concept)
          end

          it_behaves_like 'no errors response'
        end
      end

      context 'and it has no items' do
        let(:attributes) { Invoice::ValidatorSupport::QUERY.except(:items) }

        it_behaves_like 'no errors response'
      end
    end

    Invoice::Schema::REQUIRED_ATTRIBUTES.each do |attr, name|
      context "when the required field #{attr} is missing" do
        let(:attributes) { Invoice::ValidatorSupport::QUERY.except(attr) }

        it_behaves_like 'errors response', "#{name} requerido (#{attr})"
      end
    end

    Invoice::Schema::NUMERIC_ATTRIBUTES.each do |attr, name|
      context "when the numeric field #{attr} is not numeric" do
        let(:attributes) do
          Invoice::ValidatorSupport::QUERY.merge(attr => 'a')
        end

        it_behaves_like 'errors response', "#{name} debe ser un número (#{attr})"
      end
    end

    context 'when items total is inconsistent with net amount' do
      let(:attributes) do
        query = Invoice::ValidatorSupport::QUERY.deep_dup

        query[:items] << {
          name: 'Servicios de hosting',
          quantity: 1,
          unit_price: 550,
          metric_unit: 'unidades',
          total: 495,
          bonus_amount: 55,
          bonus_percentage: 10,
        }

        query
      end

      it_behaves_like 'errors response',
        'El subtotal de los items ingresados no suma el neto gravado'
    end

    Invoice::Schema::ITEM_REQUIRED_ATTRIBUTES.each do |attr, name|
      context "when an item's #{attr} is missing" do
        let(:attributes) do
          query = Invoice::ValidatorSupport::QUERY.deep_dup

          query[:items].first.delete(attr)

          query
        end

        it_behaves_like 'errors response',
          "#{name} de item requerido (#{attr} en item)"
      end
    end

    Invoice::Schema::ITEM_NUMERIC_ATTRIBUTES.each do |attr, name|
      context "when an item's numeric field #{attr} is not numeric" do
        let(:attributes) do
          query = Invoice::ValidatorSupport::QUERY.deep_dup

          query[:items].first[attr] = 'a'

          query
        end

        it_behaves_like 'errors response',
          "#{name} de item debe ser un número (#{attr} en item)"
      end
    end

    context 'when concept is invalid' do
      let(:attributes) do
        Invoice::ValidatorSupport::QUERY.merge(concept_type_id: 4)
      end

      it_behaves_like 'errors response', 'Concepto no válido'
    end

    context 'when a date value is incorrect' do
      shared_examples 'date format error response' do |attr, name|
        Invoice::ValidatorSupport::DATE_FORMATS.each do |format|
          context "when #{attr} date format is incorrect" do
            context "and its format matches '#{format}'" do
              let(:attributes) do
                query = Invoice::ValidatorSupport::QUERY.deep_dup

                query[attr] = Date.today.strftime(format)

                query
              end

              it_behaves_like 'errors response',
                "#{name} inválida o inexistente (#{attr})"
            end
          end
        end
      end

      context 'and service_from format is incorrect' do
        it_behaves_like 'date format error response',
          :service_from,
          'Fecha desde'
      end

      context 'and service_to format is incorrect' do
        it_behaves_like 'date format error response',
          :service_to,
          'Fecha hasta'
      end

      context 'and due_date format is incorrect' do
        it_behaves_like 'date format error response',
          :due_date,
          'Fecha de vencimiento'
      end

      context 'and created_at format is incorrect' do
        it_behaves_like 'date format error response',
          :created_at,
          'Fecha de comprobante'
      end
    end

    context 'when a services date is missing' do
      shared_examples 'service dates validation' do |attr, name|
        context "when #{attr} date is missing" do
          let(:base_attributes) { Invoice::ValidatorSupport::QUERY.except(attr) }
          context 'and concept includes services' do
            let(:attributes) do
              base_attributes.merge(
                concept_type_id: Invoice::Schema::CONCEPTS[:services],
              )
            end

            it_behaves_like 'errors response',
              "#{name} inválida o inexistente (#{attr})"
          end

          context 'and concept includes products and services' do
            let(:attributes) do
              base_attributes.merge(
                concept_type_id: Invoice::Schema::CONCEPTS[:products_and_services],
              )
            end

            it_behaves_like 'errors response',
              "#{name} inválida o inexistente (#{attr})"
          end

          context 'and concept does not include services' do
            let(:attributes) do
              base_attributes.merge(
                concept_type_id: Invoice::Schema::CONCEPTS[:products],
              )
            end

            it_behaves_like 'no errors response'
          end
        end
      end

      context 'when service_from date is missing' do
        it_behaves_like 'service dates validation',
          :service_from,
          'Fecha desde'
      end

      context 'when service_to date is missing' do
        it_behaves_like 'service dates validation',
          :service_to,
          'Fecha hasta'
      end
    end

    context 'when IVA information is inconsistent' do
      context 'and IVA sums zero' do
        let(:attributes) do
          Invoice::ValidatorSupport::QUERY.merge(iva: [])
        end

        it_behaves_like 'errors response',
          'Iva ingresados no compensan el total de IVA'
      end

      context 'and IVA sums more than expected' do
        let(:attributes) do
          query = Invoice::ValidatorSupport::QUERY.deep_dup
          query[:iva] << { id: 3, net_amount: 100, total_amount: 100 }

          query
        end

        it_behaves_like 'errors response',
          'Iva ingresados no compensan el total de IVA'
      end

      context 'and IVA sums less than expected' do
        let(:attributes) do
          query = Invoice::ValidatorSupport::QUERY.deep_dup
          query[:iva].pop

          query
        end

        it_behaves_like 'errors response',
          'Iva ingresados no compensan el total de IVA'
      end
    end

    context 'when taxes information is inconsistent' do
      context 'and taxes sums zero' do
        let(:attributes) do
          Invoice::ValidatorSupport::QUERY.merge(taxes: [])
        end

        it_behaves_like 'errors response',
          'Tributos ingresados no compensan el total de tributos'
      end

      context 'and taxes sums more than expected' do
        let(:attributes) do
          query = Invoice::ValidatorSupport::QUERY.deep_dup
          query[:taxes] << { id: 3, net_amount: 100, total_amount: 100 }

          query
        end

        it_behaves_like 'errors response',
          'Tributos ingresados no compensan el total de tributos'
      end

      context 'and taxes sums less than expected' do
        let(:attributes) do
          query = Invoice::ValidatorSupport::QUERY.deep_dup
          query[:taxes].pop

          query
        end

        it_behaves_like 'errors response',
          'Tributos ingresados no compensan el total de tributos'
      end
    end

    context 'when exempt amount does not match items exempt amounts' do
      Invoice::ValidatorSupport::AMOUNT_ATTRIBUTES.each do |attr|
        context "and #{attr} is wrong" do
          let(:attributes) do
            Invoice::ValidatorSupport::QUERY.merge(
              attr => Invoice::ValidatorSupport::QUERY[attr] + 100,
            )
          end

          it_behaves_like 'errors response',
            'Importe total no se condice con importes informados'
        end
      end
    end

    context 'when untaxed amount does not match items untaxed amounts' do
      let(:attributes) do
        Invoice::ValidatorSupport::QUERY.merge(
          exempt_amount: Invoice::ValidatorSupport::QUERY[:exempt_amount] - 100,
          total_amount: Invoice::ValidatorSupport::QUERY[:total_amount] - 100,
        )
      end

      it_behaves_like 'errors response',
        'La suma de los valores exentos de los items no coincide con el total exento provisto'
    end

    Invoice::Schema::NOTES_IDS.each do |note_id|
      context "when invoice is a note (ID #{note_id})" do
        context 'and a valid query is received' do
          let(:attributes) do
            query = Invoice::ValidatorSupport::QUERY.deep_dup
            query[:bill_type_id] = note_id

            query[:associated_invoices] << Invoice::ValidatorSupport::ASSOCIATED_INVOICE.dup

            query
          end

          it_behaves_like 'no errors response'
        end

        context 'and it has no associated invoices' do
          let(:attributes) do
            Invoice::ValidatorSupport::QUERY.merge(bill_type_id: note_id)
          end

          it_behaves_like 'errors response',
            'Comprobantes asociados requeridos (associated_invoices)'
        end

        Invoice::ValidatorSupport::ASSOCIATED_INVOICE.keys.each do |attr|
          context "and #{attr} is missing" do
          end
        end
      end
    end

    context 'when it is a FCE' do
      context 'and a valid query is received' do
        let(:attributes) do
          query = Invoice::ValidatorSupport::QUERY.deep_dup
          query[:bill_type_id] = '201'

          query.merge!(Invoice::ValidatorSupport::OPT_ATTRIBUTES)
        end

        it_behaves_like 'no errors response'
      end

      context 'and CBU is missing' do
        let(:attributes) do
          query = Invoice::ValidatorSupport::QUERY.deep_dup
          query[:bill_type_id] = '201'

          query
            .merge!(Invoice::ValidatorSupport::OPT_ATTRIBUTES)
            .delete(:cbu)

          query
        end

        it_behaves_like 'errors response', 'CBU requerido (cbu)'
      end

      context 'and transmission value is missing' do
        let(:attributes) do
          query = Invoice::ValidatorSupport::QUERY.deep_dup
          query[:bill_type_id] = '201'

          query
            .merge!(Invoice::ValidatorSupport::OPT_ATTRIBUTES)
            .delete(:transmission)

          query
        end

        it_behaves_like 'errors response',
          'Transmisión requerida (SCA/ADC)'
      end
    end
  end
end
