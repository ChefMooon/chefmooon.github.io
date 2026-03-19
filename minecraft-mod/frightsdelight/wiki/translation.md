{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
### {{ t.translation.section_title }}

| Language | Status | Version | Authors |
|---|---|---|---|
| `zh_cn` | Done | `1.0.2` | Qiu_Shui |
| `ru_ru` | Partial | `1.0.3` | Tkhakiro |
| `uk_ua` | Partial | `1.1.0` | unroman |
| `ko_kr` | Done | `1.4.3` | Copy-TT |

*{{ t.translation.submit_placeholder }}*
