{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
### Compatible Versions

| Minecraft | Fabric | NeoForge |
|---|---|---|
| 26.2.x | ➖ | ➖ |
| 26.1.x | ➖ | ➖ |
| 1.21-1.21.1 | ✅ (`v0.1.4`) | ✅ (`v0.1.4`) |

**{{ t.compatibility.legend_label }}** • ✅ {{ t.compatibility.supported_label }} • ❌ {{ t.compatibility.unsupported_label }} • ➕ {{ t.compatibility.bugfix_label }} • ➖ {{ t.compatibility.planned_label }}
