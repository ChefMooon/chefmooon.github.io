{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
### Compatible Versions

| Minecraft | Fabric | NeoForge | Forge |
|---|---|---|---|
| 26.2.x | ➖ | ❌ | ❌ |
| 26.1.x | ➖ | ➖ | ❌ |
| 1.21.11 | ✅ (`v1.4.5`) | ❌ | ❌ |
| 1.21.9-1.21.10 | ✅ (`v1.4.1`) | ❌ | ❌ |
| 1.21.8 | ✅ (`v1.4.1`) | ❌ | ❌ |
| 1.21.5 | ✅ (`v1.4.0`) | ❌ | ❌ |
| 1.21-1.21.1 | ✅ (`v1.3.2`) | ✅ (`v1.3.1`) | ❌ |
| 1.20.1 | ✅ (`v1.3.2*`) | ✅ (`v1.3.1`) | ✅ (`v1.3.1`) |
| 1.19.2 | ✅ (`v1.3.3`) | ❌ | ✅ (`v1.3.3`) |

**{{ t.compatibility.legend_label }}** • ✅ {{ t.compatibility.supported_label }} • ❌ {{ t.compatibility.unsupported_label }} • ➕ {{ t.compatibility.bugfix_label }} • ➖ {{ t.compatibility.planned_label }}

<p>* Compatible with Farmer's Delight Fabric (<a href="https://modrinth.com/mod/farmers-delight-fabric">Modrinth</a> or <a href="https://www.curseforge.com/minecraft/mc-mods/farmers-delight-fabric">CurseForge</a>) and Farmer's Delight Refabricated (<a href="https://modrinth.com/mod/farmers-delight-refabricated">Modrinth</a> or <a href="https://www.curseforge.com/minecraft/mc-mods/farmers-delight-refabricated">CurseForge</a>).</p>
