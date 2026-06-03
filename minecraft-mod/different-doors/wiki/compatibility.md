{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
### Compatible Versions

| Minecraft | Fabric | NeoForge | Forge |
|---|---|---|---|
| 26.2.x | ➖ | ➖ | ❌ |
| 26.1.x | ➖ | ➖ | ❌ |
| 1.21-1.21.1 | ✅ (`v1.0.0`) | ✅ (`v1.0.0`) | ❌ |
| 1.20.1 | ✅ (`v1.1.0`) | ❌ | ✅ (`v1.1.0`) |

**{{ t.compatibility.legend_label }}** • ✅ {{ t.compatibility.supported_label }} • ❌ {{ t.compatibility.unsupported_label }} • ➕ {{ t.compatibility.bugfix_label }} • ➖ {{ t.compatibility.planned_label }}
