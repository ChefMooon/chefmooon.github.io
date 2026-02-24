# Recipe Generator Test Suite

## Overview

This test suite validates the Recipe Generator plugin's ability to handle multiple recipe formats and detect format variations across Minecraft versions.

## Structure

```
_tests/
├── recipe_generator_test.rb              # Fixture + edge-case unit tests
├── recipe_generator_discovery_test.rb    # Auto-discovers recipes from _data/*/recipes
└── fixtures/
    └── recipes/
        ├── smelting_v121.json           # 1.21.1 format (wrapped ingredient)
        ├── smelting_v125.json           # 1.21.5 format (direct string)
        ├── smoking.json
        ├── crafting_shaped.json
        └── crafting_shapeless.json
```

## Running Tests

### Prerequisites

```bash
gem install minitest
```

### Run All Tests

```bash
ruby _tests/recipe_generator_test.rb && ruby _tests/recipe_generator_discovery_test.rb
```

### Run Fixture + Edge-Case Tests Only

```bash
ruby _tests/recipe_generator_test.rb
```

### Run Auto-Discovery Tests Only

```bash
ruby _tests/recipe_generator_discovery_test.rb
```

### Run Specific Test

```bash
ruby _tests/recipe_generator_test.rb --name test_smelting_old_format_v121
```

### Run with Verbose Output

```bash
ruby _tests/recipe_generator_test.rb -v
```

### Run Discovery with Recipe-Level Verbose Details (mod + type)

```bash
ruby _tests/recipe_generator_discovery_test.rb -v
```

This prints one line per discovered recipe, including its mod folder and recipe type.

If you want recipe-level discovery logs without `-v`, set:

```bash
RECIPE_DISCOVERY_VERBOSE=1 ruby _tests/recipe_generator_discovery_test.rb
```

## Test Coverage

### Ingredient Format Handling
- ✅ Old format (v1.21.1): `{"ingredient": {"item": "..."}}`
- ✅ New format (v1.21.5+): `{"ingredient": "minecraft:item"}`
- ✅ Both formats produce identical normalized output

### String Ingredient Handling
- ✅ Direct item IDs: `"minecraft:coal"`
- ✅ Tag references: `"#minecraft:logs"`
- ✅ Namespaced tags: `"#forge:storage_blocks/diamond"`

### Hash Object Ingredients
- ✅ Item objects with count: `{"item": "...", "count": 2}`
- ✅ Tag objects: `{"tag": "...", "count": 1}`
- ✅ Fluid objects: `{"fluid": "...", "amount": 1000}`
- ✅ Wrapped ingredients: `{"ingredient": "..."}`

### Recipe Type Normalization
- ✅ Crafting shaped recipes
- ✅ Crafting shapeless recipes
- ✅ Smelting recipes
- ✅ Smoking recipes
- ✅ Create recipes (`create:mixing`, `create:milling`)
- ✅ Farmer's Delight recipes (`farmersdelight:cooking`, `farmersdelight:cutting`)
- ✅ Ube's Delight recipes (`ubesdelight:baking_mat`)

### Auto-Discovery Validation
- ✅ Scans real recipe files under `_data/*/recipes/**/*.{yml,yaml,json}`
- ✅ Recursively discovers nested recipe entries with a `type`
- ✅ Normalizes each discovered recipe through `normalize_recipe_data`
- ✅ Fails fast with file path + recipe key + recipe type context

### Edge Cases
- ✅ Default count values (missing count defaults to 1)
- ✅ Default amount values (missing amount defaults to 1)
- ✅ Ingredient extraction from recipe_data

## Adding New Tests

When new recipe formats are discovered:

1. **Add fixture file** to `_tests/fixtures/recipes/`
2. **Add test method** to `recipe_generator_test.rb`
3. **Document the format change** in the test description

Example:

```ruby
def test_smelting_new_format_vXXX
  recipe = load_fixture('smelting_vXXX.json')
  result = @generator.normalize_smelting('test_recipe', recipe)
  
  assert_equal expected_value, result['field']
end
```

## Monitoring Format Changes

The Recipe Generator now tracks ingredient format variations during builds. Output will show:

```
=== Recipe Ingredient Format Report ===
normalize_input:
  direct_string: 42 occurrences
  wrapped_ingredient: 18 occurrences
  direct_object_item: 5 occurrences
=== End Format Report ===
```

**Unusual formats will be flagged as `unknown_hash_keys_*` or `unexpected_type_*`** - these indicate format changes that may need test updates.

## Continuous Integration

To run tests in CI/CD pipeline:

```bash
#!/bin/bash
ruby _tests/recipe_generator_test.rb
if [ $? -ne 0 ]; then
  echo "Fixture/edge-case tests failed!"
  exit 1
fi

ruby _tests/recipe_generator_discovery_test.rb
if [ $? -ne 0 ]; then
  echo "Auto-discovery recipe validation failed!"
  exit 1
fi
```

## Future Enhancements

- [ ] Add tests for load conditions (fabric/forge/neoforge)
- [ ] Add CI/CD integration to run tests on every commit
- [ ] Create GitHub Actions workflow for automated testing
