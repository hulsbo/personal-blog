---
layout: post
title:  "Start-up questions"
date:   2024-01-01 15:24:09 +0100
categories: jekyll update
---

Certainly! Here's a summary of your Jekyll-related questions and their concise answers:

1. **Question: What is Jekyll?**
   - **Answer**: Jekyll is a static site generator that converts text and Markdown into static HTML websites. It's blog-aware and widely used for personal, project, or documentation sites.

2. **Question: Why are the `_site` and `.jekyll-cache` folders not present on GitHub?**
   - **Answer**: This is normal. These directories are for local builds and caching and are usually included in `.gitignore`. GitHub Pages builds the site on the server, so these folders are not needed in the repository.

3. **Question: Can custom Jekyll themes be used on GitHub Pages?**
   - **Answer**: Yes, custom themes can be used. They can be created or imported, then set in the `_config.yml` file. However, ensure compatibility with GitHub Pages' environment.

4.  **Question: How to ensure the local Jekyll server automatically updates when files are changed?**
    - **Answer**: Jekyll's auto-regeneration feature does this by default. If it's not working, ensure your environment supports file watching, or use `--force_polling`. Restart the server for `_config.yml` changes.

5.  **Question: Troubleshooting why Jekyll doesn't recognize changes in the `_config.yml` file.**
    - **Answer**: Jekyll doesn't auto-regenerate for changes in `_config.yml`. You need to manually restart the Jekyll server for such changes to take effect.

This summary encapsulates the main topics and solutions discussed regarding setting up and troubleshooting a Jekyll site, particularly when integrated with GitHub Pages.