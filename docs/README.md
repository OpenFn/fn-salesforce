Creating Child Objects
======================

In order to handle nested objects, we key the children by the relationship
name.

We need to make the schema available to the parser, so that the parent's ID
can be placed in the correct field on the child record.

```js
{
  "type" : "object",
  "$schema" : "http://json-schema.org/draft-04/schema#",
  "title" : "Test Event",
  "properties" : {
    "vera__Attendance__r" : {
      "type" : "array",
      "id" : "vera__Attendance__c"
    },

   // We can't rely on the key names as the destination objects location
   // since an object may have multiple FK associations to the same object.
   // So it's important that we key by the relationship.

   // That means that we have to discover the object name for the given
   // key.

   // i.e. `vera__Boats__r` and `vera__Boats_Frilitanger__r` both
   // are associated with `vera__Boat__c`, and have different FKs.

    "vera__Boats__r" : {
      // At this node we are reflecting the 'relationship'
      "type" : "array",

      // NOTE: This is likely to change.
      //       Need to have a look around how other projects handle 'metadata'

      // For now we can use the `foreignKey` handle to describe which key to use
      // when the primary key is available.
      "foreignKey" : "vera__Third_Event__c",
      "sObject" :    "vera__Boat__c",


      "items" : {
        "type" : "object",
        "properties" : {
          "vera__Third_Event__c": { "type": "string" },
          "vera__Boat_Maker__c":  { "type": "string" }
        }
      }
    },


    "vera__Boats_Frilitanger__r" : {
      "type" : "array",
      "id" : "vera__Boat__c",
      "foreignKey" : "vera__Test_Event__c"
    }
  }
}

```

Scenario
--------

**TODO: write out expectation around parsing against a schema**
Given: foo schema, bar message
When: parsing bar 
Then: expect array of template ready objects, linked by reference.

Using JSONPath style selectors, we inspect the embedded data on the schema for
that given property.

We use template string values to set up the child objects foreign key value.

```js
{ "vera__Third_Event__c": "{parent.Id}" }
```

The idea is to have perform parse and template the values out.

The reasoning behind this 2 step approach is so that we test and review
outputs without hitting the servers. A core focus for these tools is to assist
in debugging and testing as much as possible.
