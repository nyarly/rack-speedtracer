require 'spec_helper'

describe Rack::Bug::SpeedTracer do
  let(:app) { [200, {'Content-Type' => 'text/plain'}, 'Hello World'] }

  describe 'middleware' do
    it 'take a backend and returns a middleware component' do
      Rack::Bug::SpeedTracer.new(app).should respond_to(:call)
    end

    it 'take an options Hash' do
      lambda { Rack::Cache.new(app, {}) }.should_not raise_error(ArgumentError)
    end
  end

  describe 'response' do
    it 'should set the X-TraceUrl header after rendering the response' do
      respond_with(200)
      response = get('/')

      response.headers.should include 'X-TraceUrl'
      response.headers['X-TraceUrl'].should match(/^\/speedtracer\?id=/)
    end

    it 'should respond with 200 to HEAD requests to the speedtracer endpoint' do
      respond_with(200)
      response = head('/speedtracer?id=test')

      response.status.should == 200
      response.headers['Content-Length'].to_i.should == 0
    end

    it 'should return a stored trace in JSON format' do
      sample_trace = Yajl::Encoder.encode({'trace' => {}})
      tracer = mock(Rack::Bug::SpeedTrace::Tracer)
      tracer.stub!(:to_json => sample_trace)

      respond_with(200)
      response = get('/speedtracer?id=test') do |st|
        st.database['test'] = tracer
      end

      response.body.should == sample_trace
    end

    it 'should return 404 on missing trace' do
      respond_with(404)
      response = get('/speedtracer?id=test-missing')
      response.status.should == 404
    end
  end
end
