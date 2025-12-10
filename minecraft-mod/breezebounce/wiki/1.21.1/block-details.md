---
layout: minecraft-mod/wiki/block-details

title: Block Details \| Breeze Bounce
mod_id: breezebounce
minecraft_version: 1.21.1
permalink: /breezebounce/wiki/1.21.1/block-details
---

### **Bounce Blocks**

These blocks are Wind Charge-infused, wool-like blocks that will bounce entities that touch any side. When struck by a wind charge the block becomes ‘Inflated’ for a short duration, while inflated bounce power is increased. They are available as full blocks, stairs, slabs, and posts.

**Details**
- Colours: White, Light Grey, Grey, Black, Brown, Red, Orange, Yellow, Lime, Green, Cyan, Light Blue, Blue, Magenta, Purple, Pink
- Posts can be placed horizontally
- Stairs, Slabs, and Posts can be waterlogged

**Double Bounce**  
If a sneaking player falls from a height of 2.8 blocks or more onto a non-inflated Bounce Block, the block along with any connected within a 1-block radius will become 'Inflated' for a short duration (4 seconds / 80 ticks). Entities on affected blocks bounce upward immediately.

Double Bounce Activation Details
- Player is sneaking
- Falls 2.8 blocks or more
- Block landed on is not ‘Inflated’

***Technical Details***
- When struck by a Wind Charge becomes inflated for 4s(80 ticks)
- Flammable and can be ignited by Lava
- Custom Sounds
  - When Player jumps
  - When Player bounces all sides
    - Pitch increase with greater velocity
  - Player Step
  - Inflate / Deflate

### **Inflation Machine**
A functional block that keeps a group of connected Bounce Blocks ‘Inflated’ as long as it is fueled. Inflation can extend 5 blocks to the side and 1 block above/below in a 11x11x3 area. It can also be placed on its side allowing for greater vertical Inflation(3x11x11).

 **Fuel**
- Breeze Rod ⇒ 60s(1200ticks)
- Wind Charge ⇒ 12s(240ticks)

**Redstone**

When receiving a Redstone signal the block will stop ‘Inflation’. Additionally, A Comparator signal can be obtained from this block. When storage is full it will emit a max signal strength. 