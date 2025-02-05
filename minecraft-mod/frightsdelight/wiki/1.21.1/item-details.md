---
layout: minecraft-mod/wiki/item-details

title: Item Details \| Fright's Delight
mod_id: frightsdelight
minecraft_version: 1.21.1
permalink: /frightsdelight/wiki/1.21.1/item-details
---

## General

Each food item has the chance to apply at least 1 negative Effect. The chance to be applied and duration are effected by the ingredients in the recipe and the crafting/preperation method. The rules below explain how the chance and duration are effected by the ingredients.

**Chance**
- Base 100% chance to apply negative effects
- Crafting/Cooking reduces the chance to apply negative effects by 25%
- Food on a Bone Shard reduces the chance to apply negative effects by 10%
- Food on a plate reduces the chance to apply negative effects by 25%
- Drinks reduce the chance to apply negative effects by 25%

**Duration**
- Base duration is Brief(30s)
- 1 Negative Ingredient increase duration
- Crafting/Cooking reduces duration

**Exceptions**
- Drinks
    - Positive effects duration/chance increased
    - Negative effects duration/chance decreased
- Soul and Wither Berry
    - Positive effect duration increased/chance
- Bone Kebab
    - Max effect duration 1min

**NOTE:** General rules implemented in V1.1.0

## Bone Shard
The Bone Shard is a throwable item that is used in the kebab recipe's. It is made by putting a Bone into a cutting board and using a Knife([recipe](https://chefmooon.github.io/frightsdelight/wiki/1.21.1/recipes#farmersdelight:cutting/bone_shard)).

***

## Misc Info

- While consuming drinks made from mobs you may hear their cries

### Composting Information
- Soul Berry - 30%
- Wither Berry - 30%
- Soul Berry Cookie - 85%
- Rotten Flesh Cookie - 85%
- Spider Eye Cookie - 85%

### Villager and Wandering Trader Trades
- Wandering Trader
    - 1 Emerald for 1 Soul Berry
- Butcher (Level 3)
    - 10 Soul Berries for 1 Emerald
    - 10 Wither Berries for 2 Emeralds

***

# Effect Details

7 Status Effects add a psychological “horror” element to each dish. 5 harmful Status Effects help balance each dish to add minor inconveniences or non-intrusive psychological horror elements while still providing good quality food. 2 beneficial Status Effects help by giving immunity to certain effects. 

The information about the duration and chance of effects from food is found in [Item Details](https://chefmooon.github.io/frightsdelight/wiki/1.21.1/item-details#general)

***

### Undead Hunger

![undead_hunger_icon](https://i.imgur.com/eF2EUG5.png)

Removes and grants immunity to Food Poisoning and Infected.

<details>
<summary><strong>Technical Info</strong></summary>

<strong>Main Ingredient:</strong> Wither Berry<br />
<strong>Overlay:</strong> Yes<br />
<strong>Effect Type:</strong> Neutral<br />
<br />
<ul><li>Removes and grants immunity to Food Poisoning and Infected</li></ul>
</details>

***

### Fortified Mind

![fortified_mind_icon](https://i.imgur.com/TEX8dZ4.png)

Removes and grants immunity to Hysteria and Chills.

<details>
<summary><strong>Technical Info</strong></summary>

<strong>Main Ingredient:</strong> Soul Berry<br />
<strong>Overlay:</strong> Yes<br />
<strong>Effect Type:</strong> Beneficial<br />
<br />
<ul><li>Removes and grants immunity to Hysteria and Chills</li></ul>
</details>

***

### Hysteria

![hysteria_icon](https://i.imgur.com/ru335b0.png)

Your mind may play tricks on you... Monsters can be heard near and far.(subtitles supported)

<details>
<summary><strong>Technical Info</strong></summary>

<strong>Main Ingredient:</strong> Spider Eye<br />
<strong>Overlay:</strong> Yes<br />
<strong>Effect Type:</strong> Harmful<br />
<br />
<ul>
    <li>Chance to have a “mob_sound” be made close, medium, or far distance</li>
    <li>Chance of sound is greater the more hungry the player is</li>
    <li>list of sounds: entity.skeleton.ambient, entity.zombie.ambient, entity.spider.ambient</li>
</ul>
</details>

***

### Chills

![chills_icon](https://i.imgur.com/O7SDhsz.png)

You feel a spectral presence nearby, you may feel a chill if they pass through you

<details>
<summary><strong>Technical Info</strong></summary>

<strong>Main Ingredient:</strong> Ghast Tear<br />
<strong>Overlay:</strong> Yes<br />
<strong>Effect Type:</strong> Harmful<br />
<br />
<ul>
    <li>vAt effect start subtitle is shown</li>
    <li>There is a chance the player can encounter a “ghost”</li>
    <li>Encounter only displays subtitle</li>
    <li>At effect end subtitle is shown</li>
</ul>
</details>

***

### Slime Walk

![slime_walk_icon](https://i.imgur.com/vlbMV1t.png)

Slightly decreases walking speed; you may also hear the occasional slimy sound.

<details>
<summary><strong>Technical Info</strong></summary>

<strong>Main Ingredient:</strong> Slime<br />
<strong>Overlay:</strong> Yes<br />
<strong>Effect Type:</strong> Harmful<br />
<br />
<ul>
    <li>Player movement slowed</li>
    <li>If the player is on the ground there is a chance to hear a slime squish sound</li>
</ul>
</details>

***

### Cobwebbed

![cobwebbed_icon](https://i.imgur.com/rNE1fCG.png)

Slightly decreases walking speed.

<details>
<summary><strong>Technical Info</strong></summary>

<strong>Main Ingredient:</strong> Cobweb<br />
<strong>Overlay:</strong> Yes<br />
<strong>Effect Type:</strong> Harmful<br />
<br />
<ul><li>Player movement is slowed</li></ul>
</details>

***

### Infected

![infected_icon](https://i.imgur.com/ogidyZx.png)

Greatly increases food exhaustion.

<details>
<summary><strong>Technical Info</strong></summary>

<strong>Main Ingredient:</strong> Rotten Flesh<br />
<strong>Overlay:</strong> Yes<br />
<strong>Effect Type:</strong> Harmful<br />
<br />
<ul><li>Add Exhaustion to player 2x the effect of Food Poisoning</li></ul>
</details>

***