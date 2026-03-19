### Compatible Versions

| Minecraft | Fabric | NeoForge | Forge |
|---|---|---|---|
| 1.21-1.21.1 | ✅ (`v1.0.0`) | ✅ (`v1.0.0`) | ❌ |
| 1.20.1 | ✅ (`v1.1.0`) | ❌ | ✅ (`v1.1.0`) |

{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
**{{ t.compatibility.legend_label }}** • ✅ {{ t.compatibility.supported_label }} • ❌ {{ t.compatibility.unsupported_label }} • ➕ {{ t.compatibility.bugfix_label }} • ➖ {{ t.compatibility.planned_label }}
