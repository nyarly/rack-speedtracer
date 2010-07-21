require 'rack/bug'
require 'yajl'
require 'uuid'

require 'rack/speedtracer/trace-app'
require 'rack/speedtracer/tracer'

module Rack::Bug
  class SpeedTracer < Panel
    attr_accessor :db

    def initialize(app)
      @app  = app
      @uuid = UUID.new
      @db = {}
      super
    end

    def has_content?
      false
    end

    def panel_app
      return SpeedTrace::TraceApp.new(@db)
    end

    def before(env)
      env['st.id']   = @uuid.generate
      env['st.tracer'] = SpeedTrace::Tracer.new(env['st.id'], env['REQUEST_METHOD'], env['REQUEST_URI'])
    end

    def after(env, status, headers, body)
      @db[env['st.id']] = env['st.tracer'].finish
      headers['X-TraceUrl'] = '/speedtracer?id=' + env['st.id']
    end
  end

end
