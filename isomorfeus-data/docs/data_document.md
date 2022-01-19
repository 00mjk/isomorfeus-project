### LucidDocument

allows for isomorphic access to Documents.

Documents consist of fields of textual data.
The fields are indexed by default, thus documents can be easily found by querying text in the fields.
The documents fields must be declared.

#### New Instantiation
```ruby
class MyDocument < LucidDocument::Base
  field :title
  field :text
end

a = MyDocument.new(fields: { title: 'Lets go!', text: 'Lorem ipsum ....' })

# saving the document for later reference may be useful
a.promise_save.then do
  a.key
end
```

#### Loading
```ruby
class MyDocument < LucidDocument::Base
  field :title
  field :text
end

a = MyDocument.load(key: '1234')
a.title # -> 'Lets go!'
```

#### Searching for Documents

Docs can be searched server side using the search method on the class. To make search results isomorphically available a LucidQuery::Base class must be used. The search method returns a array of documents. It accepts as query a isomorfeus-ferret query, see the
[Tutorial](https://github.com/isomorfeus/isomorfeus-ferret/blob/master/TUTORIAL.md)

```ruby
class MyDocument < LucidDocument::Base
  field :name
end

# example, server side
top_docs = MyDocument.search('name:"ferret"')

# create query class:
class MyQuery < LucidQuery::Base
  execute_query do
    { top_docs: MyDocument.search('name:"ferret"') }
  end
end

# example, client side or everywhere else in the system:
MyQuery.promise_execute.then do |query_result|
  query_result.top_docs # The hash key can be accessed with a method.
end
```

For more information about Queries and how to pass props see the [query docs](https://github.com/isomorfeus/isomorfeus-project/blob/master/isomorfeus-data/docs/data_query.md).

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/isomorfeus-data/test_app_files/isomorfeus/data/simple_document.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/isomorfeus-data/test_app_files/spec/data_document_spec.rb)

```ruby
class MyDocument < LucidDocument::Base
  field :name
end

# api
# class:
#   field :my_field, default: value
#   my_document.class.fields
#   my_document.class.field_options
# instance:
#   my_document.my_field
#   my_document.my_field = value
#   my_document.changed_fields
#   my_document.changed?
#   my_document.loaded?
#   my_document.to_transport
```
