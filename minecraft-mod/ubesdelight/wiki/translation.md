{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
### {{ t.translation.section_title }}

| Language | Status | Version | Authors |
|---|---|---|---|
| `zh_cn` | Done | `0.1.5.3` | Qiu_Shui |
| `ru_ru` | Done | `0.2.0` | mpustovoi |
| `em_mx` | Partial | `0.2.0` | TheLegendofSaram |
| `ko_kr` | Done | `0.4.11` | JaeHyuk_Lee |

*{{ t.translation.submit_placeholder }}*
