module MultiTest
  def self.disable_autorun
    if defined?(Test::Unit::Runner)
      Test::Unit::Runner.module_eval("@@stop_auto_run = true")
    end

    if defined?(Minitest)
      Minitest.instance_eval do
        def run(*)
          # propagate the exit code from cucumber or another runner
          case $!
          when SystemExit
            $!.status
          else
            true
          end
        end
      end

      if defined?(Minitest::Unit)
        Minitest::Unit.class_eval do
          def run(*)
          end
        end
      end
    end
  end

  def self.extend_with_best_assertion_library(object)
    if defined?(Test::Unit::Assertions)
      object.extend(Test::Unit::Assertions)
    end

    if defined?(Minitest::Assertions)
      object.extend(MinitestWorld)
    end

    begin
    require 'rspec/expectations'
    object.extend(::RSpec::Matchers)
    rescue LoadError
      # do nothing
    end

    begin
      require 'spec/expectations'
      require 'spec/runner/differs/default'
      require 'ostruct'
      options = OpenStruct.new(:diff_format => :unified, :context_lines => 3)
      Spec::Expectations.differ = Spec::Expectations::Differs::Default.new(options)
      object.extend(Spec::Matchers)
    rescue LoadError
      # do nothing
    end
  end

  module MinitestWorld
    def self.extended(base)
      base.extend(MiniTest::Assertions)
      base.assertions = 0
    end

    attr_accessor :assertions
  end
end
