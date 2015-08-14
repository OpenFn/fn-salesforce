# OpenFn Salesforce Adaptor

*pre-release*

CLI Tool and Adaptor for working with Salesforce.

Intended to be used in conjunction with OpenFn, but has been designed
with standalone use in mind.

Leveraging JSON-Schema, fn-salesforce acts as a bridge between Salesforce
and external data. It supports nested JSON data, and can resolve
basic dependency graphs while providing access to intermediary data
formats.


Artifacts
---------

* **Credentials**  
  In order to communicate with Salesforce, a set of API credentials should
  be available at processing time.

* **Destination Message**  
  Generic JSON document provided to the Saleforce adaptor.

* **Prepared Messages / Plan**
  Intermediary JSON document used internally to represent the order and
  the unfulfilled dependent values at the time of execution.

  The array of objects received are assumed to be in a reliable order.

* **Schema**
  JSON Schema document used to assemble a plan, linking up the SObject names
  with the relationship keys found on the destination message.

- - -

## prepare

Flattens out a message into an array of objects to be sent to Salesforce.

See the **push** interface below.

```
fn-salesforce prepare -v -s schema.json payload.json 1> plan.json
```


## push

Using a prepared message, the push step sends the objects in order to
Salesforce and fills in `$ref` values just in time.

Example message:

```js
[
  {
    "sObject": "my__ObjectName__c",
    "properties": {
      "Id": "12345"
    }
  },
  {
    "sObject": "my__ObjectName__c",
    "properties": {
      "my__Custom_Reference__c": {
        "$ref": "/0/properties/Id"
      }
    }
  }
]
```

`$ref` values use [JSON Pointers](https://tools.ietf.org/html/rfc6901)
as a lookup value. At the time of resolving the reference, the message
list will only contain the objects before it.

If you need to look ahead, it's best solved in the original data source.
So it's actually only useful in the scenario where it's impossible to know
the value without talking to Salesforce first.

The array of objects received are assumed to be in a reliable order.

## describe

Returns the object description from Salesforce.

```
$ fn-salesforce describe -c ./.credentials.json -v my__Custom_Object__c
```

It's a pretty big JSON document, so you will probably want to send it to
a file using a redirect.

`$ fn-salesforce describe ... 1>object_description.json`


CLI
---

`$ fn-salesforce COMMAND [options] [subject]`

There are a few switches used to configure the CLI client, every command
needs login credentials to communicate with Salesforce.

- `-c` `--credentials`  
  Provide a credentials file for communicating with Salesforce.
- `-v` `--verbose`  
  Show extra detail when executing commands.

`$ fn-salesforce push PAYLOAD`

Process a JSON document and create Salesforce objects.

Example

`fn-salesforce push payload.json`

`$ fn-salesforce describe OBJECT`

Describes an object. Returns JSON by default.

Example

`fn-salesforce describe User`

Tests
-----

`rspec`


## Development

After checking out the repo, run `bin/setup` to install dependencies. 
Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fn-salesforce/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
