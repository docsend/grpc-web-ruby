# frozen_string_literal: true

RSpec.describe ::GRPCWeb::GRPCRequestProcessor do
  describe '#process' do
    subject(:process) { described_class.process(call) }

    let(:call) { GRPCWeb::GRPCWebCall.new(initial_request, metadata, started: false) }
    let(:initial_request) do
      ::GRPCWeb::GRPCWebRequest.new(
        service,
        service_method,
        request_content_type,
        request_accept,
        body,
      )
    end

    let(:response_encoder) { ::GRPCWeb::GRPCResponseEncoder }
    let(:request_decoder) { ::GRPCWeb::GRPCRequestDecoder }
    let(:body) { { name: 'test' } }

    let(:decoded_request) { instance_double(::GRPCWeb::GRPCWebRequest) }
    let(:metadata) { {} }
    let(:deserialized_request) do
      instance_double(
        ::GRPCWeb::GRPCWebRequest,
        service: service,
        service_method: service_method,
        body: instance_double(HelloRequest),
        content_type: request_content_type,
        accept: request_accept,
      )
    end
    let(:service) { TestHelloService.new }
    let(:request_content_type) { ::GRPCWeb::ContentTypes::JSON_CONTENT_TYPE }
    let(:request_accept) { '*/*' }
    let(:service_method) { :SayHello }
    let(:method) { :say_hello }
    let(:service_response) { HelloResponse.new(message: 'not hello') }
    let(:encoded_response) { instance_double(::GRPCWeb::GRPCWebResponse) }

    before do
      allow(response_encoder).to receive(:encode).and_return(encoded_response)
      allow(request_decoder).to receive(:decode).and_return(body)
      allow(initial_request).to receive(:service_method).and_return(service_method)
      allow(initial_request).to receive(:service).and_return(service)
      allow(initial_request).to receive(:accept).and_return(request_accept)
      allow(initial_request).to receive(:content_type).and_return(request_content_type)
    end

    describe 'execution response' do
      context 'when the service raises an error' do
        let(:error) { StandardError.new('something went wrong') }
        let(:service) { instance_double(TestHelloService) }

        before { allow(service).to receive(:say_hello).and_raise(error) }

        it 'calls the error handler' do
          expect(::GRPCWeb.on_error).to receive(:call).with(error, service, service_method)
          process
        end
      end
    end

    it 'returns the encoded response' do
      expect(process).to eq(encoded_response)
    end
  end
end
