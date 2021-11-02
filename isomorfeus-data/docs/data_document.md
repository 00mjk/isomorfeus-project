### LucidData::Document

allows for isomorphic access to Documents.

Documents consist of set of fields of textual data.
The fields are indexed by default, thus documents can be easily found by querying text in the fields.

Documents can be part of a LusidData::Graph.
Accessing documents from edges only works within a LucidData::Graph and only if the corresponding edges and documents are included in the Graph.

### Creating a Document

The documents fields must be declared. :id and :key are reserved and must not be used as field names.

#### New Instantiation
```
class MyDocument < LucidData::Document::Base
  field :title
  field :text
end

a = MyDocument.new(fields: { title: 'Lets go!', text: 'Lorem ipsum ....' })

# saving the document for later reference may be useful
a.promise_save.then do
  a.key # after creating the document, saving it for the first time, the key is known e.g. -> '1234'
end
```

#### Loading
```
class MyDocument < LucidData::Document::Base
  field :title
  field :text
end

a = MyDocument.load(key: '1234')
a.title # -> 'Lets go!'
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_document.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_document_spec.rb)


```
class MyDocument < LucidData::Document::Base
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
