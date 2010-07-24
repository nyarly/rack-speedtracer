require 'spec_helper'
require 'rack/bug/speedtracer/profiling'

describe Rack::Bug::ProfilingSpeedTracer do
  it 'should set the X-TraceUrl header after rendering the response' do
    respond_with(200)
    response = get('/')

    response.headers.should include 'X-TraceUrl'
    response.headers['X-TraceUrl'].should match(/^\/speedtracer\?id=/)
  end
end
