### LucidData::Hash

allows for isomorphic access to a Hash.

### Creating a Hash

Hash attributes can be declared but dont have to be.

#### New Instantiation
```
class MyHash < LucidData::Hash::Base
end

a = MyHash.new(key: '1234', attributes: { color: 'FF0000', shape: 'round' })
```

#### Loading
```
class MyHash < LucidData::Hash::Base
  execute_load do |key:|
    new(key: key, attributes: { color: 'FF0000', shape: 'round' })
  end
end

a = MyHash.load(key: '1234')
a[:color] # -> 'FF0000'
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_hash.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_hash_spec.rb)
