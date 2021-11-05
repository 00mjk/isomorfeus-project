### LucidFile

allows for isomorphic access to Files.

#### Creating a File
```ruby
class MyFile < LucidFile::Base
end

a = MyFile.new()
a.promise_save do
  a.key
end
```

#### Loading
```ruby
class MyFile < LucidFile::Base
end

a = MyFile.load(key: '1234')
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_file.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_file_spec.rb)
