#!/usr/bin/env ruby
# Test runner for RecipeGenerator plugin
# Usage: ruby run_tests.rb [options]

require 'minitest'
require 'minitest/reporters'

# Setup reporter
Minitest::Reporters.use! [
  Minitest::Reporters::DefaultReporter.new(color: true),
  Minitest::Reporters::HtmlReporter.new(filename: '_tests/test_results.html')
]

# Load and run tests
Dir.glob('_tests/**/*_test.rb').each { |file| require_relative file }

Minitest.run(ARGV)
