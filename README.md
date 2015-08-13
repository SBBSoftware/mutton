#Share Handlebar Templates Between Server and Client With Rails

[![Build Status](https://travis-ci.org/SBBSoftware/mutton.svg?branch=master)](https://travis-ci.org/SBBSoftware/mutton)
[![Code Climate](https://codeclimate.com/github/SBBSoftware/mutton/badges/gpa.svg)](https://codeclimate.com/github/SBBSoftware/mutton)

Externalize your handlebar templates and render them from your server as a replacement to ERB, 
and use them unchanged through Javascript on the client. Supports the entire handlebars specification. 
Stop writing script tags and duplicating your work in ERB, every .hbs file can be served up 
directly from a controller, or through Javascript on the client.

##What is Handlebars
Cut down on view pollution by using logic-less templates. Handlebars is a beautiful progression from Mustache. 
The template engine adds in logical processing, helpers and context changing, while maintaining the beauty of
front end templating.

[Check out handlebars.js.com](http://handlebarsjs.com) for all the details

##Why is Handlebars great?
Handlebars turns the View back to a design and layout tier. 
By eliminating <% %> you are forced to code your application cleanly, with beautiful templating.

#Quick Start
Create a new Rails application.

####Add the following to your gemfile

```
gem 'mutton'
```

####Create a directory to store your templates. 

The default is `app/assets/javascript/templates`, but you can store them anywhere, 
including your views directory.
Be warned, sprockets needs to append a path 1 directory up from your template folder. DISCUSS


####Create your controllers and templates

* create a SamplesController and add the following
```
app/controllers/samples_controller.rb
class SamplesController < ApplicationController
  before_action :create_sample_data
  
  private
  
  def create_sample_data
    @greetings = [{ timing: 'morning', phrase: 'Good morning'},
    { timing: 'afternoon', phrase: 'Good afternoon'}, 
    { timing: 'evening', phrase: 'Good evening'}]
  end 
end
```

* add the following to routes.rb

```
config/routes.rb
root 'samples#index'
resources :samples
```

* create a file named index.hbs in app/assets/javascripts/templates/samples

Inside the file, code the following
```
app/assets/javascripts/templates/samples/index.hbs
<h3>Greeting List</h3>
<div id="greetingPanel">
  {{#greetings}}
    When it's {{timing}} I will say {{phrase}}<br/> 
  {{/greetings}}
</div>
```

* open your browser and navigate to http://localhost:3000/samples

That's it!

####But how did that work?
If you had created index.html.erb in app/views/samples, Rails would have found
that file instead. Mutton adds a new path to the LookupContext for Handlebars templates and registers a handler
for files with .hbs and .handlebars extensions. The template handler loads up all known handlebar 
files registered in sprockets, adds in javascript files stored in your helper directory and sends 
it all off to ExecJS to run as javascript. That's it.

####Now try and render the template client side

* create app/views/samples/index.js.erb and copy the code below

```
app/views/samples/index.js.erb
var context = <%= assigns.to_json.html_safe %>;
$('#greetingPanel').html(JHT['samples/update'](context));
```

* create app/assets/javascripts/templates/update.hbs and copy below

```
app/assets/javascripts/templates/samples/update.hbs
<p> I am the latest information on this topic
{{#greetings}}
  {{>samples/_greeting}}
{{/greetings}}

```

* create app/assets/javascripts/templates/_greeting.hbs and copy below

```
app/assets/javascripts/templates/samples/_greeting.hbs
When it's {{timing}} I will say {{phrase}}<br/> 
```

* almost there, edit app/assets/javascripts/templates/samples/index.hbs and change it to below

```
app/assets/javascripts/templates/samples/index.hbs
<h3>Greeting List</h3>
<a data-remote="true" href="/samples">Update greetings</a>
<div id="greetingPanel">
  {{#greetings}}
    When it's {{timing}} I will say {{phrase}}<br/> 
  {{/greetings}}
</div>

```

* finally, add an entry in app/assets/javascripts/application.js 
Add handlebars before require_tree so it looks like below

```
app/assets/javascripts/application.js
//= require jquery
//= require jquery_ujs
//= require mutton/handlebars.runtime
//= require templates
```

Thats it. You should now see an update link, click on it and watch the code render on your browser.

That was also a stealth introduction of a partial. When you use the helper {{>}} you're going to pass
the current context to a partial and see it render. There are a great many ways to change context, or pass
data on the fly to a partial, check out the [Handlebars documents](http://handlebarsjs.com/partials.html) for more
information.
 
While you're at it, check your rails log. You should see a 5x improvement in rendering 
time between index.hbs and index.js.erb. This is why everyone wants those single page applications!
 With Mutton, you can write on the server or the client with the same template and hear unicorns sing. 
 
####Ok, well how did that work?
Registering a template engine with sprockets allows you to process files as part of the sprockets pipeline.
 We hook into all .hbs and .handlebar files and convert them to javascript, calling the Handlebars pre-compiler
 so that we can cut down on client processing. Once they are processed, sprockets caches them and adds them to the 
 chain of javascript output from ```javascript_include_tag``` in your application layout.

####So its all the same then?
Hopefully. Node/your local javascript runtime and browsers are very different. However, Handlebars is elegantly 
namespaced and should not be affected by any other packages on the browser. On the server side, I have 
restricted files under compilation to the templates, helpers you put in a helper directory and handlebars. 
This should restrict different outcomes, but it's always possible there may be some.

##Partials
I had to make 1 compromise on partials, you have to namespace them, even if 
they are in the same directory.
For example
```
<h3>Greeting List</h3>
{{#greetings}}
  {{>samples/greeter}}
{{/greetings}}
```

As every template is namespaced with a directory and file name, partials are accessible 
only when namespaced. In addition, everything is a partial. Partials don't need any special naming, 
and you may include any template as a partial providing you access it through 
the correct namespace. Technically, instead of calling the 
register partial function, I copy the entire namespace over to the partial 
space so that everything is available.

##Javascript Helpers and Partials
If you prefer to write helpers and partials in javascript, you can do this too. 
Whatever you write, put it in your template/helpers directory and it will be included when rendering.

##Local assigns are transferred automatically

All local assigns are automatically added to the handlebar context. Be careful, every instance 
variable you create in a controller context will be sent to the browser as data if you're using 
the client side.

##Custom Configuration
In order to customize settings, create an initializer eg config/initializers/mutton.rb

Entries with notes and default values below
```
Mutton.configure do |config|
  # path to templates directory
  config.template_path = Rails.root.join('app', 'assets', 'javascripts', 'templates')
  
  # path to javascript helpers
  # every javascript file in this directory will be concatenated with
  # handlebars during compilation
  config.helper_path = File.join(Mutton.template_path, 'helpers')

  # javascript namespace for compiled templates
  # templates will be accessed by this value
  # JHT['directory/file_without_extension']
  config.template_namespace = 'JHT'

  # handlebars file for compilation
  # change this if you want to use a beta or other version
  # you dont need to wait for a gem update if handlebars
  # releases a new version
  config.handlebars_file = File.expand_path('../../../vendor/assets/javascripts/mutton/handlebars.js', __FILE__)

  # when true, instrumentation will be logged at debug level
  config.subscribe_notifications = true
end
```

##Logging
By default, template rendering on the server and hbs conversion triggered by sprockets will log to the Rails log with log level debug. 
You can turn this off in your configuration file


##Dependencies
Sprockets. Yes, you need sprockets. If you've moved to another pipeline solution you're going
to be unhappy.

ExecJs. You can leave it pick the best javascript environment or set the environment in your boot.rb file

```ENV['EXECJS_RUNTIME'] = 'Node'```

I recommend Node because, well, Node.

##So what sucks?
All right everyone, step forward if you use form helpers. Not so fast Handlebars! In order 
to move into a world without cluttered views the tradeoff is; **you have to give up Rails form helpers**. I extracted this from a project which was almost exclusively using 
javascript on the front end, so it wasn't really a hardship, but during testing I have been converting 
a more traditional application and my goodness, is it 2004 already? 
I've been thinking of how to overcome this, either adding compilation of ember and and using those helpers, 
or working on wiring Rails helpers into the mechanism. Neither solution yet appeals but probably sometime before end of year.

**The template path**. This caused more problems than the rest of the gem combined. The issue: Rails provides 
a number of hooks for an Engine or Railtie to configure settings, all but one happen after your Controllers 
have been initialized with a LookupContext. That one which is available happens before initialization files 
are processed, so there is no safe way to allow custom configured paths to be added to LookupContext. I add the 
default during pre-initialization, and if there is a custom one I use ```ApplicationController.send(:append_view_path, path)``` 
to alter Controller behavior. This is great until you dynamically reload a Controller by editing during development, 
if you're doing this you will have to restart your development server. I recommend using the default setting for now.

##What are the alternatives?
You could go completely Mustache with https://github.com/agoragames/stache . I found the gem to be excellent, but 
didn't love the template engine enough to go with it.

If you don't need server side Handlebars, the very great https://github.com/leshill/handlebars_assets has a 
similar sprockets based pipeline translation system.

If you don't need client side templating and want an elegant Ruby based solution with the ability to use helpers, you might 
want to check out https://github.com/zendesk/curly . I love the template engine, but not the 
View Presenter mechanism, not enough re-use for what I need, but it is an impressive design and beautifully 
coded.

##What's Next?
Sprockets is great, except when it isn't. I'm not thrilled with some of the design decisions I had to make 
but the payoff in simplicity and having the gem work on any new Rails app won me over. Sprockets is used consistently 
on both server and client side rendering. I think Gulp makes, or will make sprockets redundant, sort of, maybe. The problem is that there are so many different ways of using Gulp 
that designing a workable gem becomes exponentially more complex. I hope to make some headway here and see if a new Gulp-based 
version of Mutton is feasible.

Possibly adding support for Ember, but there is such a trend toward Angular that it may not be adding any value. 

##Credits
There are some really remarkable engineers whose work influenced this gem. From learning how to use ExecJS 
to finding the best way to annotate view paths during configuration. There are a few projects which demonstrated 
the concepts and techniques I have put to use here, and I would like to thank their authors:

* Les Hill (@leshill) and the contributors to handlebar_assets
* All the folks at @railsware, their shared handlebar assets gem was the best introduction to creating a template handler
* @sstephensen for Sprockets, ExecJS on which this gem relies

Finally, huge thanks to @wycats and the Handlebars team for the work of art that is Handlebars.

###Other tricks
Works great with https://github.com/gazay/gon, you can ditch your .js.erb files for the client and just do everything in a javascript file. 
With Gon, Handlebars and an onLoad event you should be able to get rid server side template processing altogether, 
provided you're down with your data being readable in the browser. 

I use a view presenter (to be released soon and pimped here as much as humanely possible) which works for erb, 
handlebars or plain old json. You can use Decorator, maybe even Cells, or just a PORO presenter. Models sent into 
 Views and accessed with Ruby are the plastic shopping bags of Rails apps, you will be shocked at how much 
 cleaner your application becomes when you can't branch 17 times or do lambda calculus in your views. Give it a try 
 even if you don't use Handlebars, find another way to sever logic and code from your view template.
 
Just remember, whatever you send in as assigns end up being used in the server parser and client, namespaced 
by variable name.

###Contributing
Yes please!
1. Fork It
2. Create a topic branch
3. Push
4. Submit a pull request
