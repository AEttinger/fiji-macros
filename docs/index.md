---
title: "Fiji macros"
description: "Collection of some Fiji macros."
---
{% for file in site.static_files %}
{% assign extension = file.extname %}
{{ file.name }}
{% endfor %}
<!--
<main role="main" class="container">
  <aside class="col-sm-2 ml-sm-auto blog-sidebar">
    <div class="sidebar-module">
      <h4>Macros</h4>
      <ol class="list-unstyled">
        {% for file in site.static_files %}
        {% assign extension = file.extname %}
        {{ file.name }}
        {% if extension == ".ijm" %}
          <li><a href="{{ file.path | prepend: repository.name | prepend: site.url }}" target="code_frame">{{ file.basename | capitalize }}</a></li>
        {% endif %}
        {% endfor %}
      </ol>
    </div>
    </aside>
</main>
--!>
