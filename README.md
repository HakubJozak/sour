# Sour

## Description

      $ bin/source2swagger -f ~/data/test/sample3.rb -c "##~"_


Add *-o /tmp* and it will write the JSON file(s) to */tmp*

#### Contributions

Feel free to extend the code and issue a pull request,

The test suite can be invoked as

      $ rake test

Requires *rake* and the *gem test/unit*


## How to

Check [test/data/sample3.rb](https://github.com/solso/source2swagger/blob/master/test/data/sample3.rb) for a comprehensive real example of the *source2swagger* inline docs for Ruby.

The names of the attributes can be seen on the section Grammar (partially) or better yet in the original [Swagger Specification](http://swagger.wordnik.com/spec).

#### API names declaration

First you need to declare the API

      ##~ a = source2swagger.namespace("your_api_spec_name")

This will generate the file your_api_spec_name.json. The name can be declared in multiple files and several times in the same file. Each time *namespace* is invoked it returns the reference to the root element of the API named "your_api_spec_name".

#### Setting attributes elements

One by one,

      ##~ a.basePath = "http://helloworld.3scale.net"
      ##~ a.swagrVersion = "0.1a"
      ##~ a.apiVersion = "1.0"

or all at the same time,

      ##~ a.set "basePath" => "http://helloworld.3scale.net", "swagrVersion" => "0.1a", "apiVersion" => "1.0"


You can always combine

      ##~ a.set "basePath" => "http://helloworld.3scale.net", "swagrVersion" => "0.1a"
      ##~ a.apiVersion = "1.0"

#### Adding and element to a list attribute

      ##~ op = a.operations.add
      ##~ op.httpMethod = "GET"
      ##~ op.tags = ["production"]
      ##~ op.nickname = "get_word"
      ##~ deprecated => false
      ##~
      ##~ op = a.operations.add
      ##~ op.set :httpMethod => "POST", :tags => ["production"], :nickname => "set_word", :deprecated => false

Two elements (*operations*) were added to *a.operations*, you can also add directly if you do not need to have a reference to the variable *op*

      ##~ a.operations.add :httpMethod => "GET", :tags => ["production"], :nickname => "get_word", :deprecated => false
      ##~ a.operations.add :httpMethod => "POST", :tags => ["production"], :nickname => "set_word", :deprecated => false


#### Adding comments

You can add comments on the inline docs specification, just use the normal comment tags of your language

    ##~ op = a.operations.add
    ##
    ##  HERE IS MY COMMENT (do not use the comment tag, e.g. ##~ but the comment tag specific of your language, in ruby #)
    ##
    ##~ op.httpMethod = "GET"


Check [test/data/sample3.rb](https://github.com/solso/source2swagger/blob/master/test/data/sample3.rb) for a comprehensive real example of the *source2swagger* inline docs for Ruby.


### Generated JSON

See specification of the fields needed to declare your API on the Swagger format you can always go to the [source](http://swagger.wordnik.com/spec)

## Naming

It's [Source2Swagger's](https://github.com/solso/source2swagger/ offspring but a lot of it was deleted, so much that only first 3 and last 1 letters from the name remained.


## License

MIT License
