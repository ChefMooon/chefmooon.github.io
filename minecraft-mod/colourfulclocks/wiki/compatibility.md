### Compatible Versions

| Minecraft | Fabric | NeoForge |
|---|---|---|
| 1.21.5 | ➖ | ➖ |
| 1.21.4 | ❌ | ❌ |
| 1.21.2-1.21.3 | ❌ | ❌ |
| 1.21-1.21.1 | ✅ (`v0.1.4`) | ✅ (`v0.1.4`) |

{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
**{{ t.compatibility.legend_label }}** • ✅ {{ t.compatibility.supported_label }} • ❌ {{ t.compatibility.unsupported_label }} • ➕ {{ t.compatibility.bugfix_label }} • ➖ {{ t.compatibility.planned_label }}
