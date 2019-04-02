---
title: "Bioimaging playground"
description: "A (more or less) random collection of scripts and macros."
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
        {% for notebook in site.notebooks %}
          <li><a href="{{ notebook.url | prepend: repository.name | prepend: site.url }}" target="code_frame">{{ notebook.title | capitalize }}</a></li>
        {% endfor %}
      </ol>
    </div>
    <div class="sidebar-module">
      <h4>Fiji</h4>
      <ol class="list-unstyled">
        {% for f in site.fiji %}
          <li><a href="{{ f.url | prepend: repository.name | prepend: site.url }}" target="code_frame">{{ f.title | capitalize }}</a></li>
        {% endfor %}
      </ol>
    </div>
    <div class="sidebar-module">
      <h4>R</h4>
      <ol class="list-unstyled">
        {% for rscript in site.r %}
          <li><a href="{{ rscript.url | prepend: repository.name | prepend: site.url }}" target="code_frame">{{ rscript.title | capitalize }}</a></li>
        {% endfor %}
      </ol>
    </div>
    </aside>
  </div>
</main>
