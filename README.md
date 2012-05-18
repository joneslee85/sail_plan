# Sail Plan #
![Sail Plan will get you up and sailing quickly](http://upload.wikimedia.org/wikipedia/commons/8/87/Tackling.png)

Sail Plan is [DockYard](http://dockyard.com)'s Rails template

## Usage ##

```
rails new app_name --old-style-hash -T -d postgresql --skip-bundle -m https://raw.github.com/dockyard/sail_plan/master/template.rb
```

## Stack ##

* Configured for [PostgreSQL](http://postgresql.org)
* [Haml](http://haml.info)
* [Compass](http://compass-style.org)
* [SimpleForm](https://github.com/plataformatec/simple_form)
* [Exceptional.io](http://exceptional.io)
* [Modernizr](http://modernizr.com) (through a [CDN](http://www.cdnjs.com))
* [EasyAuth](https://github.com/dockyard/easy_auth)
* [Kaminari](https://github.com/amatsuda/kaminari)

### Devlopment Environment ###

* [QuietAssets](https://github.com/evrone/quiet_assets)
* [Debugger](https://github.com/cldwalker/debugger)

### Testing Environment ###

* [RSpec](https://www.relishapp.com/rspec)
* [Capybara](https://github.com/jnicklas/capybara)
* [CapybaraWebkit](https://github.com/thoughtbot/capybara-webkit)
* [CapybaraEmail](https://github.com/dockyard/capybara-email)
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

## Authors ##

* [Brian Cardarella](http://twitter.com/bcardarella)

## Legal ##

[DockYard](http://dockyard.com), LLC &copy; 2012

[@dockyard](http://twitter.com/dockyard)

[Licensed under the MIT license](http://www.opensource.org/licenses/mit-license.php)
