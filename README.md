# Moonshine
[![Gitter](https://badges.gitter.im/Join Chat.svg)](https://gitter.im/nebulab/moonshine?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![GemVersion](https://badge.fury.io/rb/moonshine.png)](http://badge.fury.io/rb/moonshine)
[![BuildStatus](https://travis-ci.org/nebulab/moonshine.png?branch=master)](https://travis-ci.org/nebulab/moonshine)
[![CoverageStatus](https://coveralls.io/repos/nebulab/moonshine/badge.png?branch=master)](https://coveralls.io/r/nebulab/moonshine?branch=master)
[![CodeClimate](https://codeclimate.com/github/nebulab/moonshine.png)](https://codeclimate.com/github/nebulab/moonshine)

Moonshine is a configuration driven method chain builder.

Usually writing a conditional method chain requires a lot of if and case
statements that increase code complexity, reduce code readability and make
testing hard. Moonshine removes this complexity by providing a way to call a
list of methods based on some input parameters. A completely object-oriented
approach also ensures an easily testable interface.

## Why Moonshine?

Moonshine has been built to solve a problem which is particularly obvious when
building complex REST APIs. A good API usually filters data based on parameters
passed via a GET or POST request, from a Rails point of view controller
`params[]` are used to filter down data kept in `ActiveRecord` models.

Usually to achieve this task you use [Ransack](https://github.com/activerecord-hackery/ransack),
or [HasScope](https://github.com/plataformatec/has_scope) or some hacky solution
[like this](http://stackoverflow.com/questions/1658990/one-or-more-params-in-model-find-conditions-with-ruby-on-rails).
With Moonshine you can do similar things without being restricted to using
`ActiveRecord` and with code which is easy to test.

A real world example with a Rails REST API is best to explain what Moonshine's
power is. If you define a class like this:

```ruby
  class PostFilter < Moonshine::Base
    subject -> { Post }

    param :category
    param :with_tags
  end
```

Then in your controller you can:

```ruby
  class PostController < ApplicationController
   def index
      @posts = PostFilter.new(params).run
    end
  end
```

So when you receive a request like this:

```
  GET http://my.awesome-blog.com/posts?category=cats&with_tags=cute,lovely
```

Moonshine creates a method chain based on the parameters passed. In this case
the `category` and `with_tags` methods are called on the `Post` class with
`cats` and `cute,lovely` as argument values.

## Installation

As usual you can install it using [Bundler](http://bundler.io) by adding it
to your application's Gemfile:

```ruby
  gem 'moonshine'
```

And then executing:

```ruby
  $ bundle
```

Or you can install it yourself by running:

```ruby
  $ gem install moonshine
```

## Usage

Now we'll take a look at how we can use Moonshine in a Rails application.
Moonshine supports any kind of object but probably its advantages on a Rails
application are more obvious so we'll start with a quick example with Rails.

Let's pretend we have an ActiveRecord model like this:

```ruby
  #
  # The schema
  #
  create_table :posts do |t|
    t.string :title
    t.text :description
    t.boolean :published

    t.timestamps
  end

  #
  # The model
  #
  class Post < ActiveRecord::Base
    scope :title_starts, -> (title) { where('title LIKE ?', "#{title}%") }
    scope :desc_like,    -> (desc)  { where('description LIKE ?', "%#{desc}%") }
    scope :created_at,   -> (date)  { where(created_at: date) }
    scope :published,    ->         { where( published: true ) }
  end
```

we can add a `PostQuery` class inherited from `Moonshine::Base` somewhere in
our Rails application (for example in the `/lib` directory) to manage method
chaining, in this case we are mostly chaining scopes:

```ruby
  class PostQuery < Moonshine::Base
    subject -> { Post }

    param :title_starts
    param :description_has, call: :desc_like
    param :published, as_boolean: true
    param :created_at, transform: :string_to_date
    param :limit, default: 10

    param :in_season do |subject, season|
      date_range = case season
        when :summer then Date.parse('2014/06/01')..Date.parse('2014/08/31')
        when :winter then Date.parse('2014/12/01')..Date.parse('2014/02/28')
        when :autumn then Date.parse('2014/09/01')..Date.parse('2014/11/30')
        when :spring then Date.parse('2014/03/01')..Date.parse('2014/05/30')
      end

      subject.where( created_at: date_range )
    end

    def self.string_to_date(string_date)
      string_date.to_date
    end
  end
```

### Running the chain

After defining the `PostQuery` class we can run method chains with it on the
specified `subject`. An example run is like this:

```ruby
  PostQuery.new({ title_starts: 'moonshine', in_season: :summer }).run
```

In the end we'll have the result of the execution of the method chain on the
`subject` object. In this case we'll have the `ActiveRecord::Relation` returned
by the various scopes being called on `Post`. In case Moonshine has to run an
empty chain (for example when no params are passed to it) the `subject` will be
returned.

### Configuring the chain

Let's take a look at each line of code to understand what Moonshine is all
about.

### Subject

```ruby
  subject -> { Post }
```

The subject is what the chain will be called on. It must be a block, proc or
lambda. When you run a method chain each method will be called on the `subject`
(which is evaluated at every run) and the result of the chain of methods called
will be the returned value.

In our Rails example every method or scope which is added to the chain will be
called, in order, on the `Post` subject. Since we're talking scopes here you can
see where this is going, Moonshine will build a long list of scopes and call it
for you.

### Param

The basic parameter is without arguments, when the chain is run it will look for
a method defined on the `subject` and call it with given parameter value.

```ruby
  param :title_starts
```

Calling the chain like this:

```ruby
  PostQuery.new({ title_starts: 'moonshine' }).run
```

will run a `title_starts` scope on the `Post` model with 'moonshine' as an
argument.

### call

When the `subject` doesn't have a method named after the `param` argument,
you can add `call` to specify the actual method to call.

```ruby
  param :description_has, call: :desc_like
```

Calling the chain like this:

```ruby
  PostQuery.new({ description_has: 'cool stuff!' }).run
```

will run the `desc_like` scope on the `Post` model with 'cool stuff!' as an
argument.

### as_boolean

When a method doesn't take any arguments you can add it to the method chain by
setting the `as_boolean` to `true`. This will make Moonshine call the method
based on the value passed to the `PostQuery` object.

```ruby
  param :published, as_boolean: true
```

This means that calling a chain like this:

```ruby
  PostQuery.new({ published: true }).run
```

will end up running the `published` scope on the `Post` model. In case it was
`published: false` Moonshine would have just returned `Post` since the chain
would be empty (no method needed to be called).

### default

If you need a method in the chain to return a default value you can use the
`default` option. As you would expect this would return the default value when
the chain is run whithout that parameter in the chain.

```ruby
  param :limit, default: 10
```

### transform

At times you may need to transform the values you are passing to the chain for
example when reading `params[]` you may need to transform something from string
to whatever you need in your model. In such occasions you can use the `trasform`
option.

```ruby
  param :created_at, transform: :string_to_date

  def self.string_to_date(string_date)
    string_date.to_date
  end
```

So a run like:

```ruby
  PostQuery.new({ created_at: '2014/06/01' }).run
```

will end up using the `created_at` scope and passing in the actual `Date`
object.

### block

When total customization needs to be achieved and you don't feel adding more
code to the `Post` model, you can pass a block to execute that block instead of
any other method.

```ruby
  param :in_season do |subject, season|
    date_range = case season
      when :summer then Date.parse('2014/06/01')..Date.parse('2014/08/31')
      when :winter then Date.parse('2014/12/01')..Date.parse('2014/02/28')
      when :autumn then Date.parse('2014/09/01')..Date.parse('2014/11/30')
      when :spring then Date.parse('2014/03/01')..Date.parse('2014/05/30')
    end

    subject.where( created_at: date_range )
  end
```

# Moonshine for everything!

Even if this readme is heavily Rails-centered, remember that Moonshine can build
method chains to be run on any object. This is because the `subject` can be any
object you'd like.

Take a look at this quick example with a string:

```ruby
  class StringQuery < Moonshine::Base
    subject -> { 'a dog' }

    param :capitalize, as_boolean: true
    param :append, call: :concat
    param :concat, transform: :reverse

    param :append_a_cat do |subject, value|
      "#{subject} #{value} with a cat"
    end

    param :upper, call: :upcase, as_boolean: true

    def self.reverse(value)
      value.reverse
    end
  end
```

```ruby
  StringQuery.new({ upper: true }).run
  => "A DOG"

  StringQuery.new({}).run
  => "a dog"

  StringQuery.new({ capitalize: true }).run
  => "A dog"

  StringQuery.new({ append: ' go around' }).run
  => "a dog go around"

  StringQuery.new({ concat: 'tac a dna ' }).run
  => "a dog and a cat"

  StringQuery.new({ append_a_cat: 'go around', upper: true }).run
  => "A DOG GO AROUND WITH A CAT"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
