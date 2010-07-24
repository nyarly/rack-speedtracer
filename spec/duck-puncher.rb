require "spec_helper"
require "rack/bug/speedtracer/duck-puncher"

describe "Duck punching" do
  describe "::find_constant" do
    it "should find constants" do
      find_constant("Rack::Bug").should == Rack::Bug
    end

    it "should yield constants" do
      find_constant("Rack::Bug") do |rb|
        rb.should == Rack::Bug
      end
    end
    
    it "should swallow exceptions when constants aren't found" do 
      expect do 
        find_constant("I::Made::This::Up")
      end.to_not raise_error
    end
  end
  describe "with tracing" do

    before :each do
      @tracer = Rack::Bug::SpeedTrace::Tracer.new(0, 'GET', '/test')
      Thread.current["st.tracer"] = @tracer

      @test_class = Class.new do
        class << self
          def klass_method(a,b,c)
            b
          end
        end

        def instance_method(a,b,c)
          a << b
          a << c
        end

        def other_instance_method
        end
      end
    end

    it "should trace instance methods" do
      @test_class.trace_methods :instance_method

      test_instance = @test_class.new

      array = []
      test_instance.instance_method(array, 1, 2)
      array.should include(1,2)

      @tracer.finish.to_json.should =~ /"operation":\s*{\s*"label":\s*"#instance_method\(\[\],1,2\)"/m
    end

    it "should trace class methods" do
      @test_class.trace_class_methods :klass_method

      @test_class.klass_method([5],6,7).should == 6
      @tracer.finish.to_json.should =~ /"label":\s*"::klass_method\(\[5\],6,7\)"/


    end
  end
end
