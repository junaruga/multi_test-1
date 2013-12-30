module MultiTest
  def self.disable_autorun
    if defined?(Test::Unit::Runner)
      Test::Unit::Runner.module_eval("@@stop_auto_run = true")
    end

    if defined?(Minitest)
      Minitest.instance_eval do
        def run(*)
          0 # exit code
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
end
