require 'rspec/rails'

RSpec.shared_examples 'HTTP 100 response' do
  it 'returns an HTTP 100 response' do
    subject

    expect(response).to have_http_status(:continue)
  end
end

RSpec.shared_examples 'HTTP 200 response' do
  it 'returns an HTTP 200 response' do
    subject

    expect(response).to have_http_status(:ok)
  end
end

RSpec.shared_examples 'HTTP 201 response' do
  it 'returns an HTTP 201 response' do
    subject

    expect(response).to have_http_status(:created)
  end
end

RSpec.shared_examples 'HTTP 204 response' do
  it 'returns an HTTP 204 response' do
    subject

    expect(response).to have_http_status(:no_content)
  end
end

RSpec.shared_examples 'HTTP 400 response' do
  it 'returns an HTTP 400 response' do
    subject

    expect(response).to have_http_status(:bad_request)
  end
end

RSpec.shared_examples 'HTTP 404 response' do
  it 'returns an HTTP 404 response' do
    subject

    expect(response).to have_http_status(:not_found)
  end
end

RSpec.shared_examples 'HTTP 502 response' do
  it 'returns an HTTP 502 response' do
    subject

    expect(response).to have_http_status(:bad_gateway)
  end
end

RSpec.shared_examples 'PDF response' do
  it 'renders PDF' do
    subject

    expect(response.headers['Content-Type']).to eq('application/pdf')
  end
end
