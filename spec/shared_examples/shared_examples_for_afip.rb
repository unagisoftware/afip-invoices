require 'rspec/rails'

RSpec.shared_examples 'AFIP connection errors management' do |operation|
  let(:message) { { param: 'test' } }

  context 'when external service connection raises Savon::SOAPFault' do
    before do
      stub_savon_error(
        Savon::SOAPFault.new(build_http_object, nil),
        operation,
      )
    end

    it 'raises connection error' do
      expect { subject.call(operation, message) }.to raise_error(
        Afip::InvalidRequestError,
        "Error de conexión con AFIP: solicitud inválida con error 'error message'.",
      )
    end
  end

  context 'when external service connection raises Savon::HTTPError' do
    before do
      stub_savon_error(
        Savon::HTTPError.new(build_http_object),
        operation,
      )
    end

    it 'raises connection error' do
      expect { subject.call(operation, message) }.to raise_error(
        Afip::UnsuccessfulResponseError,
        "Error de conexión con AFIP: respuesta no exitosa (HTTP 500) con error 'error message'.",
      )
    end
  end

  context 'when external service connection raises Savon::InvalidResponseError' do
    before do
      stub_savon_error(
        Savon::InvalidResponseError.new(build_http_object),
        operation,
      )
    end

    it 'raises connection error' do
      expect { subject.call(operation, message) }.to raise_error(
        Afip::InvalidResponseError,
        'Error de conexión con AFIP: respuesta de servidor inválida.',
      )
    end
  end

  context 'when external service connection raises Net::ReadTimeout' do
    before do
      stub_savon_error(
        Net::ReadTimeout,
        operation,
      )
    end

    it 'raises connection error' do
      expect { subject.call(operation, message) }.to raise_error(
        Afip::TimeoutError,
        'Error de conexión con AFIP: timeout de conexión con AFIP.',
      )
    end
  end

  context 'when service raises StandardError' do
    before do
      stub_savon_error(
        StandardError,
        operation,
      )
    end

    it 'raises connection error' do
      expect { subject.call(operation, message) }.to raise_error(
        Afip::UnexpectedError,
        'Error de conexión con AFIP: error no esperado.',
      )
    end
  end

  private

  def stub_savon_error(error, operation)
    allow_any_instance_of(Savon::Client)
      .to receive(:call)
      .and_call_original

    allow(error).to receive(:to_s).and_return('error message')

    allow_any_instance_of(Savon::Client)
      .to receive(:call)
      .with(operation, message: an_instance_of(Hash))
      .and_raise(error)
  end

  def build_http_object
    http = OpenStruct.new
    http.code = 500

    http
  end
end

RSpec.shared_examples 'AFIP WS operation execution' do |operation|
  let(:message) { { param: 'test' } }

  it_behaves_like 'AFIP connection errors management', operation
  it_behaves_like 'AFIP connection errors management', :login_cms

  it 'connects with external service and fetches information' do
    subject.call(operation, message)

    afip_mocks.each do |mock|
      expect(mock).to have_been_requested
    end
  end
end
