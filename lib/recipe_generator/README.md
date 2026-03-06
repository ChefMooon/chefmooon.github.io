# RecipeGenerator Plugin — Architecture

This directory contains the modular components of the `RecipeGenerator` Jekyll plugin.
The main entry point remains `_plugins/recipe_generator.rb`, which acts as a thin coordinator.

## Directory Structure

```
_plugins/
  recipe_generator.rb              # Coordinator: wires modules, owns generate + process_nested_recipes
  recipe_generator/
    schema_registry.rb             # Central type → { schema, normalize_method } registry
    load_conditions.rb             # normalize_load_conditions, loader_folder?, VALID_LOADERS
    ingredient_normalizers.rb      # normalize_input, normalize_combined_input, normalize_smithing_input,
                                   # extract_ingredient, normalize_tool
    output_normalizers.rb          # normalize_output (generic — used by vanilla, FD, ubes)
    validation.rb                  # validate_recipe, validate_create_recipe, log_validation_error,
                                   # log_validation_summary
    tag_collection.rb              # collect_tags_*, validate_tags, log_tag_validation_summary
    lang_processor.rb              # process_lang_data, process_item_lang_data, process_block_lang_data
    mods/
      mod_vanilla.rb               # minecraft:crafting_shaped/shapeless/smithing/smelting/smoking/campfire
      mod_farmersdelight.rb        # farmersdelight:cutting, farmersdelight:cooking
      mod_create.rb                # create:milling, create:mixing, create:emptying, create:filling
      mod_ubesdelight.rb           # ubesdelight:baking_mat
```

## How It Works

All utility modules and mod modules define **instance methods** inside `Jekyll::RecipeGenerator`
sub-modules. The main class `include`s all of them, so every normalizer method is available as a
private instance method on the generator — this preserves compatibility with the existing test suite
which calls methods via `send`.

### Dispatch Flow

1. `generate` collects pages with `layout: minecraft-mod/wiki/recipes`.
2. For each recipe entry, `process_nested_recipes` calls `validate_recipe` then `normalize_recipe_data`.
3. `normalize_recipe_data` calls `SchemaRegistry.lookup(type)` to get the registered
   `normalize_method` symbol, then dispatches via `send(normalize_method, key, recipe_data)`.
4. The method lives in the appropriate mod module (already mixed into the class).

## SchemaRegistry API

```ruby
# Register a type (called at the bottom of each mod file at load time)
SchemaRegistry.register(
  'minecraft:smelting',
  schema: {
    required_fields: ['ingredient', 'result'],
    field_types: { 'ingredient' => [Hash, String], 'result' => [Hash, String] }
  },
  normalize_method: :normalize_smelting
)

SchemaRegistry.lookup('minecraft:smelting')         # => { schema: ..., normalize_method: :normalize_smelting }
SchemaRegistry.schema_for('minecraft:smelting')     # => { required_fields: [...], field_types: {...} }
SchemaRegistry.normalize_method_for('minecraft:smelting')  # => :normalize_smelting
SchemaRegistry.all_types                            # => ['minecraft:smelting', ...]
```

Create recipes register `schema: nil` because they use the flexible `validate_create_recipe`
validator instead of the standard field-type checker.

## Adding a New Mod

1. Create `lib/recipe_generator/mods/mod_newmod.rb`.
2. Define `module Jekyll::RecipeGenerator::Mods::NewMod` with private normalizer methods.
3. Call `SchemaRegistry.register` at the bottom of the file for each handled recipe type.
4. Add `include RecipeGenerator::Mods::NewMod` to the class body in `_plugins/recipe_generator.rb`.
5. Add `require 'mods/mod_newmod'` in `_plugins/recipe_generator.rb` (after the class stub is defined).

No other changes are needed. The registrations are self-contained within each mod file.

## Shared Utilities vs. Mod-Specific Code

| Belongs in shared utilities | Belongs in mod file |
|---|---|
| Used by 2+ mods | Used by exactly one mod |
| Generic ingredient/output format | Mod-specific fluid/amount fields |
| `normalize_input`, `normalize_combined_input` | `normalize_create_output`, `normalize_milling_output` |
| `normalize_tool` (FD + ubes) | `normalize_processing_stages` (ubes only) |

## Load Conditions & Loader Folders

`normalize_load_conditions` reads `fabric:load_conditions`, `neoforge:conditions`, or `conditions`
(Forge) keys from raw recipe data. `loader_folder?` identifies folder names like `fabric/`, `neoforge/`
during `process_nested_recipes` traversal so loader-specific recipe variants are tagged correctly.
