{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
### Compatible Versions

| Minecraft | Fabric | NeoForge |
|---|---|---|
| 1.21.11 | ✅ (`v1.3.0`) | ✅ (`v1.3.0`) |
| 1.21.10 | ✅ (`v1.3.0`) | ✅ (`v1.3.0`) |
| 1.21.8 | ✅ (`v1.3.0`) | ✅ (`v1.3.0`) |
| 1.21.5 | ✅ (`v1.3.0`) | ✅ (`v1.3.0`) |
| 1.21.4 | ➕ (`v1.2.1`) | ➕ (`v1.2.1`) |
| 1.21.2-1.21.3 | ➕ (`v1.2.1`) | ➕ (`v1.2.1`) |
| 1.21-1.21.1 | ✅ (`v1.3.0`) | ✅ (`v1.3.0`) |

**{{ t.compatibility.legend_label }}** • ✅ {{ t.compatibility.supported_label }} • ❌ {{ t.compatibility.unsupported_label }} • ➕ {{ t.compatibility.bugfix_label }} • ➖ {{ t.compatibility.planned_label }}
