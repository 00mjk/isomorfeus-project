### LucidData::Graph

allows for isomorphic access to graphs.
Graph must be build with LucidData::Collection objects which contain the nodes/documents and LucidData::EdgeCollection objects which contain the edges.

### Creating a Graph

#### Declaration of collection accessors
A Graph can have attributes.
Collection accessors can be declared, but dont have to be.
In case they are not declared all nodes are available by calling the nodes method on the graph instance, all edges can be accessed with the edges method.

Declaring node and edge collection accessors:
```
class MyGraph < LucidData::Graph::Base
  nodes :important_tasks
  nodes :other_tasks
  nodes :contractors
  edges :contractors_important_tasks_edges
  edges :contractors_other_tasks_edges
end
```

#### New Instantiation
Assuming we have above class MyGraph and in addition the LucidData classes for each collection as declared above::
```
c = MyGraph.new(key: '1234',
  nodes: {
    # pass node collections as hash with keys names as declared
    important_tasks: ImportantTasks.new(key: '1'),
    other_tasks: OtherTasks.new(key: '1'),
    contractors: Contractors.new(key: '2') },
  edges: {
    contractors_important_tasks_edges: ContractorITEdges.new(key: '1'),
    contractors_other_tasks_edges: ContractorOTEdges.new(key: '1')
  }
})
```

#### Loading
```
class MyGraph < LucidData::Graph::Base
  execute_load do |key:|
    new(key: '1234',
      nodes: {
        # pass node collections as hash with keys names as declared
        important_tasks: ImportantTasks.new(key: '1'),
        other_tasks: OtherTasks.new(key: '1'),
        contractors: Contractors.new(key: '2') },
      edges: {
        contractors_important_tasks_edges: ContractorITEdges.new(key: '1'),
        contractors_other_tasks_edges: ContractorOTEdges.new(key: '1')
      }
    )
  end
end
```

### Accessing data of a Graph
access methods are available for each of the declared parts of a composition:

```
g = MyGraph.load(key: '123456')

g.important_tasks # -> ImportantTasks Collection instance
g.other_tasks # -> OtherTasks Collection instance
g.contractors # -> Contractors Collection instance
g.contractors_important_tasks_edges # -> ContractorITEdges EdgeCollection instance
g.contractors_other_tasks_edges # -> ContractorOTEdges EdgeCollection instance
```

### Example and Specs
- [Example](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/isomorfeus/data/simple_graph.rb)
- [Specs](https://github.com/isomorfeus/isomorfeus-project/blob/master/ruby/isomorfeus-data/test_app_files/spec/data_graph_spec.rb)
