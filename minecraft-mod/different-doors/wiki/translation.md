{%- assign t = site.data.i18n[site.active_lang].strings -%}
{%- unless t -%}{%- assign t = site.data.i18n.en.strings -%}{%- endunless -%}
### {{ t.translation.section_title }}

{{ t.translation.no_contributors_yet }}

*{{ t.translation.submit_placeholder }}*
