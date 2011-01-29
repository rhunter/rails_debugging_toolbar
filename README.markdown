# Render Debugging Toolbar for Rails

If you are looking at the front end of a Rails app and see something you want to
work on, there are several ways you might answer the question:

## Which template is rendering that particular chunk of HTML?

If you have simple views, logical markup and your URLs map very quickly to
views, then you can probably just open your editor and guess pretty much
exactly where you need to edit. You're in the Rails happy place, and you
probably don't need a tool to help you.

If you're working on a less-happy Rails application, however, you might have
some of the following impediments:

 * hundreds of similarly-named views
 * complex views with partials within partials
 * URLs that don't map so easily quickly and obviously to view filenames
 * markup without obviously unique patterns to search for

I was in this situation recently; I found myself wishing for something
to just tell me where the HTML was coming from.

# The Render Debugging Toolbar helps you find your view

There are tools that let you interactively point at the different parts of
your page and tell you a bunch of back-end information.

Drupal has the [Drupal Theme Developer][1], Django has the
[Django Debug Toolbar][2], but I couldn't find anything to
help me out when I asked Rails the same question of this Rails app:
"What is generating that HTML right there?"

The Render Debugging Toolbar aims to be that tool for Rails.

# Installation

  Add the following to the "development" group in your Gemfile:
    gem "rails-render-debugging-toolbar"
  Bundler will take care of the rest when you run
    bundle install
  
  If you're not using Bundler, you won't have a Gemfile, so you'll need
  to install the gem manually.

# Usage

The toolbar needs a lot of extra markup to do its work, so you probably won't
want to leave it enabled all the time. You can turn it on for a single request
by adding the query parameter "?debug=render" to a request.

For example, if you are interested in the page:

    http://localhost:3000/examples/new

You can try the toolbar by visiting the following:

    http://localhost:3000/examples/new?debug=render

When the toolbar is enabled, you should see a little debugging checkbox overlaid
on top of the normal page. Switch it on, and then everything you point at should
show a panel of debugging information about what rendered it.

Simply point at the element you're interested in, and the panel will tell you
where the view is.



[1]: http://drupal.org/project/devel_themer
[2]: https://github.com/robhudson/django-debug-toolbar


# License

Copyright 2011 Rob Hunter and ThoughtWorks, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
