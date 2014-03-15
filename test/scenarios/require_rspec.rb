# Imagine this is your rails app
require 'rspec'

# Now cucumber loads
require "multi_test"
MultiTest.disable_autorun

# Now we create the world
MultiTest.extend_with_best_assertion_library(self)

# Now we execute a scenario and assert something
expect(1).to eq(1)

