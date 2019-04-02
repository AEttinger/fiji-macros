---
title: "Fiji macros"
description: "Collection of some Fiji macros."
---
<main role="main" class="container">
  <div class="row">
    <div class="col-sm-10 blog-main">  
      <div class="embed-responsive embed-responsive-16by9">
      <iframe class="embed-responsive-item" src="https://aettinger.github.io/bioimaging-playground/test.html" name="code_frame"><p>Iframe not supported.</p></iframe>
      </div>
    </div>
  <aside class="col-sm-2 ml-sm-auto blog-sidebar">
    <div class="sidebar-module">
      <h4>Jupyter Notebooks</h4>
      <ol class="list-unstyled">
        {% for file in site.static_files %}
        {% if file.extname == ".ijm" %}
          <li><a href="{{ file.path | prepend: repository.name | prepend: site.url }}" target="code_frame">{{ file.basename | capitalize }}</a></li>
        {% endif %}
        {% endfor %}
      </ol>
    </div>
    </aside>
  </div>
</main>
