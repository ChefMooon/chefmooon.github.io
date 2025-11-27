---
layout: minecraft-mod/wiki/block-details

title: Block Details \| Ube's Delight
mod_id: ubesdelight
minecraft_version: 1.21.5
permalink: /ubesdelight/wiki/1.21.5/block-details

quick_links:
    - alt: Wild Crops
      href: wild-crops
    - alt: Punch Bowls
      href: punch-bowls
    - alt: Glass Cup
      href: glass-cup
    - alt: Leaf Feasts
      href: leaf-feasts
    - alt: Cakes and Flan
      href: cakes-and-flan
    - alt: Baking Mat
      href: baking-mat
---

## Wild Crops

All wild crops only spawn naturally in the following biomes; Jungle, Bamboo Jungle, and Sparse Jungle. They can be found next to specific flowers, and some with Tall Grass.

**Ube:** Wild Ube, Cornflower  
**Garlic** Wild Garlic, Pink Tulip  
**Ginger:** Wild Ginger, Lily of the Valley  
**Lemongrass:** Wild Lemongrass, Azure Bluet 

Biomes can be added with datapacks, see here(datapack info coming soon).

As of V0.2.0 Wild Crop spawning can be changed with datapacks
- Fabric
    - Uses c:jungle
    - Biomes can now be added to a Whitelist/Blacklist
    - data/ubesdelight/tags/worldgen/biome/has_wild_ube_whitelist.json
    - data/ubesdelight/tags/worldgen/biome/has_wild_ube_blacklist.json
- Forge
    - Uses minecraft:jungle, minecraft:bamboo_jungle, minecraft:sparse_jungle
    - Biomes can be added to allowed_boimes/denied_biomes
    - data/ubesdelight/forge/biome_modifier/wild_ube.json

## Punch Bowls

Punch Bowls are large versions of drinks you are able to place, providing multiple drink servings. 

### Usage

- Halo Halo
- Ube Milk Tea

The block must be placed to retrieve the servings. When placed, with a glass bottle in the main hand, players can use (right click) on the block to retrieve a serving. Servings can also be added back if there is space.

Each Punch Bowl provides 4 servings, when no servings are left the last drops of the contained liquid will remain. The block can be broken with a knife, servings will drop when broken.

### Redstone

This block gives off a redstone signal that can be interpreted by a redstone comparator. The signal strength depends on the amount of servings in the block. 4 Servings = 8 Signal Strength.

***

## Glass Cup

This is a placeable version of drinks. It can contain 1-4 servings and face any direction.

### Usage

**Supported Drinks**
- Halo Halo
- Ube Milk Tea

**Placing**
- Shift-Right Click on a block to place.

**Picking Up**
- Right-Click the placed Glass Cup with an empty hand to pick up.
- Servings also drop when the block is broken. 

**Rotating**
- Right-Click the placed Glass Cup with any tool to rotate.

***

## Leaf Feasts

Leaf Feasts are large versions of consumable items you are able to place, they are on a “Banana Leaf”. This block has 3 main shapes End, Middle, and Tip.
When placed beside each other and facing the same direction these blocks will connect.

The block can contain 3-6 servings depending on the shape:
- Middle = 6
- End/Tip = 3

This block has special varaints that can be created by adding(right-click) an edible food item.

**Universal Variant**   
Created when adding any item that is edible. Can display 1-6 items depending on shape.

**Special Variants**   
Created when adding a valid item. 

**Valid items**: Lumpia, Ensaymada, Ube Ensaymada, Pandesal, Ube Pandesla, Hopia Munggo, Hopia Ube, Sinangag, Cooked Rice, Fried Rice

Notes
- Sinangag, Cooked Rice, and Fried Rice
    - Bowls are required to take a serving
    - When broken will only drop the Leaf Feast

### Redstone

This block gives off a redstone signal that can be interpreted by a redstone comparator. The signal strength depends on the amount of servings in the block. 6 Servings = 12 Signal Strength.

***

## Cakes and Flan

Cakes and Flan are multi-serving food items that need to be placed before servings can be retrieved.

### Usage

- Ube Cake
- Leche Flan

The block must be placed to retrieve the slices. When placed, with a knife in the main hand, players can use (right click) on the block to retrieve a slice. Cakes contain 7 slices, Flans contain 5 slices.

### Redstone

This block gives off a redstone signal that can be interpreted by a redstone comparator. The signal strength depends on the amount of servings in the block. 7 Slices = 14 Signal Strength (Flan max 10).

***

## Baking Mat

The Baking Mat is a workstation where players can combine up to 9 items into 1 or more outputs; a matching tool must also be used. A recipe may also contain additional processing stages.

### Usage

**Crafting**

Items can be placed on the Baking Mat by using them on it. Items can be added from the main or off hand. The Rolling Pin must be in the main hand to be used.

When the correct tool is used on a matching recipe, the recipe will either spawn the results or require additional usages of the tool as a recipe can contain additional processing stages. Results will be output towards the lighter coloured side of the Baking Mat, this is to allow the automatic collection of results. The tool receives 1 point of damage for each use.

The Baking Mat supports 27 recipes.

### Redstone

This block gives off a redstone signal that can be interpreted by a redstone comparator. The signal strength depends on the amount of items in the block. 9 Items = 9 Signal Strength. A Dispenser with a Rolling Pan can also be used.

### Supported Recipes

Vanilla and Farmer's Delight recipes have the same recipe input and output with an added chance output to each. Recipe output can be found below. Ube's Delight Recipes can be found [here](https://github.com/ChefMooon/ubes-delight/wiki/Recipes)

Ube’s Delight:

- Ginger Cookie: 8 + 4(25%)
- Ube Cookie: 8 + 4(25%)
- Ube Cake: 1 + 1 (50%)
- Pandesal: 4 + 2(25%)
- Ube Pandesal: 4 + 2(25%)
- Ensaymada: 2 + 1(25%)
- Ube Ensaymada: 2 + 1(25%)
- Hopia Munggo: 2 + 1(25%)
- Hopia Ube: 2 + 1(25%)
- Polvorone: 4 + 2(25%)
- Pinipig Polvorone: 4 + 2(25%)
- Ube Polvorone: 4 + 2(25%)
- Cookies & Cream Polvorone: 4 + 2(25%)

Farmers Delight:

- Wheat Dough(egg): 3 + 1(25%)
- Wheat Dough(water): 3 + 1(25%)
- Raw Pasta(egg): 1 + 1(20%)
- Raw Pasta(water): 2 + 1(20%)
- Sweet Berry Cookie: 8 + 4(25%)
- Honey Cookie: 8 + 4(25%)
- Pie Crust: 1 + 1(25%)
- Apple Pie: 1 + 1(50%)
- Sweet Berry Cheesecake: 1 + 1(50%)
- Chocolate Pie: 1 + 1(50%)

Vanilla:

- Bread: 1 + 1(20%)
- Cookie: 8 + 4(25%)
- Pumpkin Pie: 1 + 1(25%)
- Cake: 1 + 1 (50%)

### Custom Recipes

#### Template

**No Processing Stages, Single Result, Tool Item**

```
{
  "type": "ubesdelight:baking_mat",
  "ingredients": [
    {
      "item": "namespace:item"
    },
    {
      "tag": "namespace:tag"
    }
  ],
  "processing_stages": [],
  "result": [
    {
      "item": {
        "count": 1,
        "id": "item": "namespace:result_1"
      }
    }
  ],
  "tool": {
    "item": "namespace:item"
  }
}
```

**Processing Stages, Multiple Results, Tool Tag**

```
{
  "type": "ubesdelight:baking_mat",
  "ingredients": [
    {
      "item": "namespace:item"
    },
    {
      "tag": "namespace:tag"
    }
  ],
  "processing_stages": [
    {
      "item": "namespace:item"
    }
  ],
  "result": [
    {
      "item": {
        "count": 1,
        "id": "namespace:result_1"
      }
    },
    {
      "chance": 0.25,
      "item": {
        "count": 1,
        "id": "namespace:result_2"
      }
    }
  ],
  "tool": {
    "tag": "namespace:tag"
  }
}
```

#### Elements

**Required**

- **ingredients**: The input items needed for the recipe. You must specify between 1-9 ingredients. Each ingredient can be either a specific item or an item tag.
- **processing_stages**: An array of intermediate items that appear during recipe crafting. While this field is required, it can be empty ([]) for simple recipes. For multi-stage recipes, you can specify up to 5 stages. Each stage requires one use of the specified tool to progress, and the final result is only produced after completing all stages.
- **tool**: Specifies which tool must be used to process this recipe. Can be either a specific item or an item tag.
- **result**: Defines what items the recipe produces. Must specify between 1-4 items, where each item needs both an "id" and "count".

**Optional**

- **result/chance**: A probability value between 0.0 (0%) and 1.0 (100%) that determines how likely the result item(s) will drop when processing completes. For example, 0.25 means a 25% chance to get the item.