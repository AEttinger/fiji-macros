---
title: "Fiji macros"
description: "Collection of some Fiji macros."
---

{% for file in site.static_files %}
{{ file.name }}
{% endfor %}

{% for repo in site.public_repositories %}
{{ repo }}
{% endfor %}
