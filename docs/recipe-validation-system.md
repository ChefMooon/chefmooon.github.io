# Recipe Validation System

## Overview

The Recipe Validation System is built into the custom Jekyll plugin (`_plugins/recipe_generator.rb`) that processes recipe data for all Minecraft mods. It runs automatically during every build and covers two distinct areas of validation:

### Recipe Schema Validation

Validates individual recipe files against type-specific schemas before and after normalization, catching malformed or incomplete recipe definitions.

- Checks that all required fields are present for a given recipe type
- Checks that field values have the expected data types (e.g. `Hash`, `Array`, `String`)
- Validates both raw input data (pre-normalization) and the normalized output structure
- Logs a per-recipe warning for each failure and a per-page summary at the end
- Invalid recipes are skipped from the final output; the build always completes

### Tag Definition Validation

Validates that every ingredient tag referenced in a recipe has a corresponding human-readable definition in the version-specific tag definition file (`_data/tags/{version}.yml`). Tags without a definition would render as a raw ID on wiki pages instead of a display name.

- Collects all tag IDs used across inputs, outputs, and smithing-specific fields
- Compares them against `_data/tags/{version}.yml` at the end of each page's processing
- Logs a warning for each undefined tag and a summary if any are missing
- Warns if the tag definition file for a version doesn't exist at all

## How It Works

### Validation Schemas

Each recipe type has a schema defined in `RECIPE_SCHEMAS` that specifies:
- **Required fields**: Fields that must be present
- **Field types**: Expected data types for each field (e.g., `Hash`, `String`, `Array`, `Integer`)

Supported recipe types and their required fields:

| Recipe Type | Required Fields |
|---|---|
| `minecraft:crafting_shaped` | `pattern`, `key`, `result` |
| `minecraft:crafting_shapeless` | `ingredients`, `result` |
| `minecraft:smithing_transform` | `addition`, `base`, `template`, `result` |
| `minecraft:smelting` | `ingredient`, `result` |
| `minecraft:smoking` | `ingredient`, `result` |
| `minecraft:campfire_cooking` | `ingredient`, `result` |
| `ubesdelight:baking_mat` | `tool`, `ingredients`, `processing_stages`, `result` |
| `farmersdelight:cutting` | `tool`, `ingredients`, `result` |
| `farmersdelight:cooking` | `ingredients`, `result` |
| `create:milling` | `ingredients`, `results`, `processingTime` |
| `create:mixing` | `ingredients`, `results` |
| `create:emptying` | `ingredients`, `results` |
| `create:filling` | `ingredients`, `results` |

### Validation Points

Recipes are validated at **two points** during processing:

#### 1. Pre-Normalization Validation
When a recipe file is discovered, raw recipe data is validated against its schema:
- Checks that all required fields exist
- Checks that field types match expectations
- If validation fails: Recipe is logged but skipped; does not proceed to normalization

#### 2. Post-Normalization Validation
After normalization completes, the result is checked for required output structure:
- Ensures `type`, `input`, and `output` fields are present and non-null
- Catches errors where normalization succeeded but produced incomplete data
- If validation fails: Recipe is logged and skipped from final output

## Build Output

When a recipe has invalid data, you'll see a warning message like this:

```
Recipe validation failed for 'candy_pie_slice' (farmersdelight:cutting): field 'tool' is String but expected Hash
```

Or with multiple errors:

```
Recipe validation failed for 'my_recipe' (create:milling): missing required field 'ingredients'; field 'results' is NilClass but expected Array
```

### Summary Report

After processing each mod wiki page, a summary is logged showing how many recipes failed:

```
Recipe Validation Summary: [ubesdelight v1-21-8] | 35 ubesdelight:baking_mat | 12 farmersdelight:cutting (123 processed successfully)
```

This means:
- **ubesdelight v1-21-8**: Failed validation summary for this mod and version
- **35 ubesdelight:baking_mat**: 35 baking_mat recipes failed
- **12 farmersdelight:cutting**: 12 cutting recipes failed
- **(123 processed successfully)**: 123 recipes passed and are included in the output

## Fixing Invalid Recipes

When you see validation errors in the build output:

1. **Find the recipe file** in `_data/{mod_id}/recipes/{version}/`
2. **Check the error message** to see which field is problematic
3. **Verify the field exists** and has the correct data type:
   - Object fields should be YAML objects (indented key-value pairs), not strings
   - Array fields should be YAML arrays (list of items with `-`)
   - String fields should be quoted or directly readable as strings
4. **Verify required fields** - all fields listed in the schema must be present

### Common Issues

**Issue: "field 'X' is String but expected Hash"**
- **Cause**: Field contains a string value but should be an object
- **Fix**: Check YAML indentation. If you need an object, indent the properties on the next line

**Issue: "missing required field 'X'"**
- **Cause**: Required field is not present in the recipe
- **Fix**: Add the missing field or remove the recipe if it doesn't support this type

**Issue: "field 'X' is Array but expected Hash"**
- **Cause**: Field is a list but should be a single object
- **Fix**: Check if you accidentally made it a list when it should be singular

## Adding New Recipe Types

To add validation support for a new recipe type:

1. **Open** `_plugins/recipe_generator.rb`
2. **Find** the `RECIPE_SCHEMAS` constant near the top of the class
3. **Add a new entry** following the pattern below:

```ruby
'my:recipe_type' => {
    required_fields: ['field1', 'field2', 'field3'],
    field_types: { 
        'field1' => [Hash], 
        'field2' => [Array], 
        'field3' => [Hash, String]  # Multiple acceptable types
    }
}
```

4. **Add a normalization method** (if not already present):

```ruby
def normalize_my_recipe_type(key, recipe_data)
    {
        'filename' => key,
        'load_conditions' => normalize_load_conditions(recipe_data),
        'type' => recipe_data['type'],
        'input' => normalize_combined_input(recipe_data['ingredients']),
        'output' => normalize_output(recipe_data['result'])
    }
end
```

5. **Add a case statement** in `normalize_recipe_data()`:

```ruby
when 'my:recipe_type'
    normalize_my_recipe_type(key, recipe_data)
```

6. **Test** by running: `bundle exec jekyll serve` and checking for validation messages

## Build Behavior

- ✅ **Build completes successfully** even with invalid recipes
- ✅ **Invalid recipes are logged** during build with clear error context
- ✅ **Recipes are silently skipped** from the final output if validation fails
- ✅ **Only valid recipes** appear on wiki pages
- ✅ **Summary shows count** of failures to help identify data issues

## Debugging

To see all validation errors for a specific mod version:

1. Run: `bundle exec jekyll serve` or `bundle exec jekyll build`
2. Search the output for: `Recipe validation failed` and the mod/version combination
3. Count occurrences by recipe type to prioritize fixes

To test a specific recipe file locally in Ruby:

```ruby
require './_plugins/recipe_generator.rb'
gen = Jekyll::RecipeGenerator.new

# Test validation
result = gen.send(:validate_recipe, 'my_recipe', recipe_data, 'minecraft:crafting_shaped')
puts result[:errors] unless result[:valid]
```

## Tag Validation

In addition to recipe-level validation, the build also verifies that every ingredient tag used in recipes has a corresponding definition in the version-specific tag definition file. This ensures that tags render correctly in the wiki (as human-readable names rather than raw IDs).

### How It Works

1. After normalizing each recipe, the plugin walks all ingredient fields (`input`, `addition`, `template`, `output`) and collects every `tag.id` value used.
2. At the end of processing each mod wiki page, the collected tags are compared against the tag definition file for that version.
3. Any tag that is used but not defined is logged as a warning.

### Tag Definition Files

Tag definitions live in `_data/tags/` with one file per Minecraft version:

```
_data/tags/
  1-20-1.yml
  1-21-1.yml
  1-21-5.yml
  1-21-8.yml
  1-21-10.yml
  1-21-11.yml
```

Each file is a flat YAML mapping of tag ID to display name:

```yaml
c:ingots/iron: Iron Ingot
c:ingots/gold: Gold Ingot
c:ingots/netherite: Netherite Ingot
c:eggs: Egg
forge:ingots/iron: Iron Ingot   # forge namespace used in 1.20.x
```

The version folder name (e.g. `1-21-5`) must match the folder name used inside `_data/{mod_id}/recipes/`.

### Build Output

When a tag used in a recipe has no definition, you'll see:

```
Missing tag definition 'c:ingots/netherite' (ubesdelight v1-21-5)
```

After processing the full page, a summary line is logged if any are missing:

```
Tag Validation Summary: 2 undefined tag(s) in [ubesdelight v1-21-5]: c:ingots/netherite, c:tools/knife
```

If the tag definition file for a version is missing entirely:

```
Tag Validation: No tag definition file found for version '1-22-0' (ubesdelight). Expected _data/tags/1-22-0.yml
```

### Adding a Missing Tag Definition

1. Find the tag ID in the build output warning (e.g. `c:ingots/netherite`).
2. Open the appropriate file in `_data/tags/` for the Minecraft version reported.
3. Add an entry:

```yaml
c:ingots/netherite: Netherite Ingot
```

The display name is shown in the wiki recipe card wherever that tag is used as an ingredient.

### Adding a Tag File for a New Version

Create `_data/tags/{version-folder}.yml` where the version folder matches the recipe data directory name. Populate it with all tags used by recipes for that version. The file can start minimal and grow as new recipes are added — the build will warn you about any missing entries.

### What Tags Are Collected

The plugin collects tags from the following normalized recipe fields:

| Field | Recipe Types |
|---|---|
| `input` | All recipe types (single ingredient or array) |
| `addition` | `minecraft:smithing_transform` |
| `template` | `minecraft:smithing_transform` |
| `output` | All recipe types (single ingredient or array) |

Only ingredients stored as `{ "tag": { "id": "..." } }` are collected. Item-based ingredients (`{ "item": { "id": "..." } }`) are not checked against the tag definition files.

## Smithing Recipe Format Support

The smithing recipe normalizer handles multiple data formats:

**String format** (new, 1.21+):
```yaml
addition: "#c:ingots/netherite"  # Tag prefix with #
base: "ubesdelight:rolling_pin_diamond"  # Direct item
template: "minecraft:upgrade_template"
```

**Object format** (old, 1.20-1):
```yaml
addition:
  tag: "forge:ingots/netherite"
base:
  item: "ubesdelight:rolling_pin_diamond"
template:
  item: "minecraft:upgrade_template"
```

Both formats are automatically converted to the normalized structure during processing, so mixing formats across versions is handled transparently.

## Related Files

- **Plugin**: [`_plugins/recipe_generator.rb`](../_plugins/recipe_generator.rb)
- **Recipe Schemas**: `RECIPE_SCHEMAS` constant, lines 13-63 in recipe_generator.rb
- **Recipe Validation Methods**: `validate_recipe()` and `log_validation_error()`, lines 75-120 in recipe_generator.rb
- **Tag Collection Methods**: `collect_tags_from_ingredient()` and `collect_tags_from_recipe()`, lines 123-149 in recipe_generator.rb
- **Tag Validation Methods**: `validate_tags()` and `log_tag_validation_summary()`, lines 151-175 in recipe_generator.rb
- **Recipe Data**: `_data/{mod_id}/recipes/{version}/`
- **Tag Definitions**: `_data/tags/{version}.yml`

## Quick Reference

| Action | Where |
|---|---|
| Add validation schema for new recipe type | `recipe_generator.rb`, `RECIPE_SCHEMAS` constant |
| Add normalization for new recipe type | `recipe_generator.rb`, `normalize_recipe_data()` method |
| See recipe validation errors during build | Build output, search for `Recipe validation failed` |
| See recipe validation summary per mod version | Build output, search for `Recipe Validation Summary` |
| Add a missing tag definition | `_data/tags/{version}.yml` |
| See tag validation warnings during build | Build output, search for `Missing tag definition` |
| See tag validation summary per mod version | Build output, search for `Tag Validation Summary` |
| Add tag definitions for a new version | Create `_data/tags/{version-folder}.yml` |
| Test recipe validation manually | Use `validate_recipe()` private method in Ruby |
