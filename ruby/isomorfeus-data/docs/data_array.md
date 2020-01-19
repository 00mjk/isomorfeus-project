### LucidData::Array

allows for isomorphic access of serializable data in a array.

### Creating a Array

#### New Instantiation
```
class MyArray < LucidData::Array::Base
end

a = MyArray.new(key: '1234', elements: ['a', 'b', 3, 4])
a[0] # -> 'a'
```

#### Loading
```
class MyArray < LucidData::Array::Base
  execute_load do |key:, current_user:, pub_sub_client:|
    { key: key, elements: ['a', 'b', 3, 4] }
  end
end

a = MyArray.load(key: '1234')
a[0] # -> 'a'
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_array.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_array_spec.rb)
