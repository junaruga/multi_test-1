require 'active_support/testing/autorun'

require "multi_test"
MultiTest.disable_autorun

# Now we create the world
world = Object.new
MultiTest.extend_with_best_assertion_library(world)

# Now we execute a scenario and assert something
world.assert_equal(1,1)
