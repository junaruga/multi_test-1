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

  module MinitestWorld
    def self.extended(base)
      base.extend(Minitest::Assertions)
      base.assertions = 0
    end

    attr_accessor :assertions
  end

  def self.extend_with_best_assertion_library(object)
    extenders = [
      AssertionLibrary.new(
        proc { require 'rspec/expectations' },
        proc { object.extend(::RSpec::Matchers) },
      ),
      AssertionLibrary.new(
        proc {
          require 'spec/expectations'
          require 'spec/runner/differs/default'
          require 'ostruct'
        },
        proc {
          options = OpenStruct.new(:diff_format => :unified, :context_lines => 3)
          Spec::Expectations.differ = Spec::Expectations::Differs::Default.new(options)
          object.extend(Spec::Matchers)
        },
      ),
      AssertionLibrary.new(
        proc { require 'minitest/assertions' },
        proc { object.extend(MinitestWorld) },
      ),
      AssertionLibrary.new(
        proc { require 'minitest/unit' },
        proc { object.extend(MinitestWorld) },
      ),
      AssertionLibrary.new(
        proc { require 'test/unit/assertions' },
        proc { object.extend(Test::Unit::Assertions) },
      ),
    ]
    e = extenders.detect(&:require?).extend_world(object)
  end

  class AssertionLibrary
    def initialize(requirer, extender)
      @requirer = requirer
      @extender = extender
    end

    def require?
      begin
        @requirer.call
        true
      rescue LoadError
        false
      end
    end

    def extend_world(world)
      @extender.call(world)
    end
  end

end
