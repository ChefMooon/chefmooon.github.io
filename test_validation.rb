require 'json'
recipe_data = JSON.parse(File.read('_data/frightsdelight/recipes/1-21-11/fabric/integration/create/mixing/cobweb_syrup.json'))

puts "results is Array? #{recipe_data['results'].is_a?(Array)}"
puts "results: #{recipe_data['results'].inspect}"
puts "results is nil: #{recipe_data['results'].nil?}"

puts "fluid_results is Array? #{recipe_data['fluid_results'].is_a?(Array)}"
puts "fluid_results: #{recipe_data['fluid_results'].inspect}"
puts "fluid_results is nil: #{recipe_data['fluid_results'].nil?}"

has_any_output = (recipe_data['results'].is_a?(Array) && recipe_data['results'].any?) || (recipe_data['fluid_results'].is_a?(Array) && recipe_data['fluid_results'].any?)
puts "has_any_output: #{has_any_output}"

