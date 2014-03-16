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
      [
        proc { require 'rspec/expectations' },
        proc { object.extend(::RSpec::Matchers) },
      ],
      [
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
      ],
      [
        proc { require 'minitest/assertions' },
        proc { object.extend(MinitestWorld) },
      ],
      [
        proc { require 'minitest/unit' },
        proc { object.extend(MinitestWorld) },
      ],
      [
        proc { require 'test/unit/assertions' },
        proc { object.extend(Test::Unit::Assertions) },
      ],
    ]
    e = extenders.detect do |requirer, extender|
      begin
        requirer.call
        true
      rescue LoadError
        false
      end
    end

    e.last.call(object)
  end

end
