require 'active_support/testing/autorun'

require "multi_test"
MultiTest.disable_autorun

# Now we create the world
MultiTest.extend_with_best_assertion_library(self)

# Now we execute a scenario and assert something
assert_equal(1,1)
