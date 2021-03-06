# Sail Plan #
![Sail Plan will get you up and sailing quickly](http://upload.wikimedia.org/wikipedia/commons/8/87/Tackling.png)

Sail Plan is [DockYard](http://dockyard.com)'s Rails template

## Usage ##

```
rails new app_name --old-style-hash -T -d postgresql --skip-bundle -m https://raw.github.com/DockYard/sail_plan/master/template.rb
```

## Stack ##

* Configured for [PostgreSQL](http://postgresql.org)
* [Haml](http://haml.info)
* [Compass](http://compass-style.org)
* [SimpleForm](https://github.com/plataformatec/simple_form)
* [Exceptional.io](http://exceptional.io)
* [Modernizr](http://modernizr.com) (through a [CDN](http://www.cdnjs.com))
* [EasyAuth](https://github.com/DockYard/easy_auth)
* [BackboneJS](backbonejs.org)
* [haml_coffee_assets](https://github.com/netzpirat/haml_coffee_assets)
* [WillPaginate](https://github.com/mislav/will_paginate)
* [Pages](https://github.com/DockYard/pages)
* [Thin](https://github.com/macournoyer/thin)
* [Google Frame is being turned on](http://www.google.com/chromeframe)

### Devlopment Environment ###

* [QuietAssets](https://github.com/evrone/quiet_assets)
* [Debugger](https://github.com/cldwalker/debugger)

### Testing Environment ###

* [RSpec](https://www.relishapp.com/rspec)
* [Capybara](https://github.com/jnicklas/capybara)
* [Poltergiest](https://github.com/jonleighton/poltergeist)
* [CapybaraEmail](https://github.com/DockYard/capybara-email)
* [FactoryGirl](https://github.com/thoughtbot/factory_girl)
* [Bourne](https://github.com/thoughtbot/bourne)
* [ValidAttribute](https://github.com/bcardarella/valid_attribute)
* [Timecop](https://github.com/jtrupiano/timecop)
* [Debugger](https://github.com/cldwalker/debugger)
* [Fivemat](https://github.com/tpope/fivemat)
* [DatabaseCleaner](https://github.com/bmabey/database_cleaner)

### Environment Additions ###

* `app/assets/fonts` has been added to the asset pipeline
* `application.css` has been renamed to `application.css.sass` and it always requires `app/assets/stylesheets/application/index.css.sass`
* A print style sheet has been added: `app/assets/stylesheets/print.css.sass` that always requires `app/assets/stylesheets/print/index.css.sass`

## Notes ##

The template expects [PhantomJS](http://phantomjs.org) to be installed
via [Homebrew](http://mxcl.github.com/homebrew). If `PhantomJS` is not
installed the template will make a single attempt to install. If that
attempt fails the template will exit.

## Authors ##

* [Brian Cardarella](http://twitter.com/bcardarella)
* [Dan McClain](http://twitter.com/_danmcclain)

## Legal ##

[DockYard](http://dockyard.com), LLC &copy; 2012

[@DockYard](http://twitter.com/DockYard)

[Licensed under the MIT license](http://www.opensource.org/licenses/mit-license.php)
