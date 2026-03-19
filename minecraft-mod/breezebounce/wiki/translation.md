{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
### {{ t.translation.section_title }}

| Language | Status | Version | Authors |
|---|---|---|---|
| `zh_cn` | Done | `1.1.1` | Qiu_Shui |

*{{ t.translation.submit_placeholder }}*
