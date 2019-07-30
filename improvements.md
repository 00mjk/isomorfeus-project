Jan Biedermann [18:42 Uhr]
@Frederic ZINGG ive been thinking a bit. i think, the railsy record-relation approach starts biting back. We are constantly requesting partial graphs. which is fine, but now makes trouble. What we should request, is a complete graph for a certain view in any case.

So for now, we have: `my_org.plan` and we get a record
1) what we want is: `my_org.plan_graph` and we get all nodes and edges. (bearbeitet) 
2) in addition to that, also instead of keeping track of individual records for pubsub, we should keep track of graphs, and the DB should tell us, if a update is needed, or which graphs are affected by a certain operation. (bearbeitet) 

so 1) can be used like, for example: `nodes, edges = my_org.plan_graph`
i think that would be relatively easy to implement

for 2) i think we need support on the db side, i really wish for db support here, as in the long term, we are out of luck trying to keep track of every possible change and what it affects.

for 1) we could just at some place define something like `plan_graph includes: :actions, :indicators, :outcomes, :whatever, :something_else`
to keep it easy, relying on the defined relations, but where `:something_else` could be a collection_query
for example

Frederic ZINGG [19:02 Uhr]
@Jan Biedermann I'm processing what you just wrote and see if I got what you mean.
Detail: It is not `my_org.plan` but `my_org.plans` (HAS_MANY plan), right ?
Bu tI guess it the same, just have: `@plan.plan_graph` right ? (bearbeitet) 

Jan Biedermann [19:03 Uhr]
i refine: `graph :plan, includes: { nodes: [:actions, :indicators, ...], edges: [:get_all_associated_edges] }`
so you have:
```ruby
class Org
  has_many :actions, bla bla
  bla bla
  etc.

  graph :plan_graph, includes: { nodes: [:actions, :indicators, ...], edges: [:get_all_associated_edges] }
end
```
sort of, still needs refinement, somewhere needs to be the plan_id
```ruby
class Org
  has_many :actions, bla bla
  bla bla
  etc.

  graph :plan_graph, start: Plan, includes: { nodes: [:actions, :indicators, ...], edges: [:get_all_associated_edges] }
end
```
you would then use it like:
```ruby
   my_org.plan_graph(my_plan.id)
```
How about that?
it would then find the Plan with the id, server side, and call all the methods from the includes to fill the nodes and edges arrays
so server side:
```
  def plan_graph(id) # automatically defined by meta programming
    start = Plan.find(id)
    nodes = []
    node_includes each do |ni|
      nodes << start.send(ni)
   end
  # same for edges
  return [nodes, edges]
end
```
(bearbeitet)

sort of
for pub sub, we could keep record of the nodes/edges belonging to a graph, with a redis hash, and then we call publish_graph
if we consistently use this scheme, then we mostly(or even only) need publish_graph
we should introduce a Graph class, as result of the graph meta thing, which allows us to get my_graph.nodes, my_graph.edges and
maybe: my_graph.refresh or even my_graph.save
save would just dump the nodes and edges to the db
also it should have: my_graph.start, the starting point, that would the plan node/record in above example.

Frederic ZINGG [19:17 Uhr]
ok, nice, I understand, that would be awesome and it is surely the direction have to follow because each Graph will be more and more a super beast to control.
And what about infos about `associated_actions(outcome.id)`, etc ... Just need to browse the Graph Hash on client side, right ?

Jan Biedermann [19:17 Uhr]
i see, let me think a bit more

Frederic ZINGG [19:19 Uhr]
Btw , talking about super graph, I realized yesterday that lot of linking where not solved with the CONNECTING PLANS version I did before, so finally I fix a lot of issues and start to have super nice CYPHER :bigsmile: :
```
rest_method(:get_associated_edges, default_result: []) do
    query_result = Plan.neo4j_session.query(
        "MATCH (a:Plan)-[:CONSISTS_OK|:LEADS_TO|:HAS]-(b)-[:ACTIVATING|:CONTRIBUTES_TO|:INDICATING|:TRACKS|:ACTIONS|:OUTCOMING]->(c)  WHERE a.uuid = {uuid} AND ((b:Action) OR (b:Outcome) OR (b:Indicator)) AND ((c:Action) OR (c:Outcome) OR (c:Indicator)) AND c.plan_uuid = {uuid} RETURN DISTINCT b.uuid, c.uuid, b.updated_at, c.updated_at, b.shape, c.shape ORDER BY b.uuid, c.uuid" +
        " UNION " +
        "MATCH (a:Plan)-[:ADOPTS_KEYOUTCOME]-(b)-[:TRACKS|:ACTIONS|:OUTCOMING]->(c)  WHERE a.uuid = {uuid} AND (b:Outcome) AND ((c:Action) OR (c:Outcome) OR (c:Indicator)) AND c.plan_uuid = {uuid} RETURN DISTINCT b.uuid, c.uuid, b.updated_at, c.updated_at, b.shape, c.shape ORDER BY b.uuid, c.uuid" +
        " UNION " +
        "MATCH (a:Plan)-[:CONSISTS_OK|:LEADS_TO|:HAS]-(b)-[:ACTIVATING|:CONTRIBUTES_TO|:INDICATING|:TRACKS|:ACTIONS|:OUTCOMING]->(c)  WHERE a.uuid = {uuid} AND ((b:Action) OR (b:Outcome) OR (b:Indicator)) AND c:Outcome AND (a:Plan)-[:ADOPTS_KEYOUTCOME]->(c:Outcome) RETURN DISTINCT b.uuid, c.uuid, b.updated_at, c.updated_at, b.shape, c.shape ORDER BY b.uuid, c.uuid", uuid: uuid)
    query_result.map { |row| { id: "#{row[1]}_#{row[2]}", from: row[1], to: row[2], updated_at: [row[3], row[4]].max} }
    #if want links with dashes : {dashes: edge_dashes(row[5], row[6])}
  end
```

Jan Biedermann [19:20 Uhr]
:der_schrei:
nice

Frederic ZINGG [19:21 Uhr]
cause evrything is connected now :der_schrei:
Pasted image at 2019-04-02, 6:21 PM 


Jan Biedermann [19:22 Uhr]
ok, the Graph class could make the things it consists of accessible, like:
```
... includes: :actions ...
then it could have:
my_graph.actions
```
but that doesnt feel good. becasue when updating the graph client side, this will make trouble, how to know a added node belongs to :actions?
so lets forget that
@Frederic ZINGG you the query master :yoga:

Frederic ZINGG [19:24 Uhr]
What I love with GRAPH query, it is that you just need to follow the Graph to write your QUERY.

Jan Biedermann [19:26 Uhr]
Ok, in that case, we would have simple finders for my_graph, so that i can do:
`o = my_graph.find(:outcome, id)`
and then i request from that outcome an new graph
`o.all_associated_actions`, which would be a graph too
problem solved?

Frederic ZINGG [19:28 Uhr]
yes, but would need to `pubsub` all graph and subgraph when update, right ?

Jan Biedermann [19:29 Uhr]
Ok, i call that isomorfeus-graph for now
It does not know anything, but it provides class Node, Edge, Graph
Node could be a record, so we can have:
```ruby
class MyNode
  include Isomorfeus::Node
  include Isomorfeus::Record
  etc. pp
```
but it could also be like:
```ruby
class MyNode
  include Isomorfeus::Node
  
  find do |id|
    # put query here
  end
```
something like that
pubsub, the publish graph, or publish record, would look up, which graphs include the record and would send a update message to those graphs
and this should happen in a promise chain on the client.
or the server has a generic “get_graphs” where we send the request to. thats even better than the promise chain
so we can get as many graphs as we want in one request

Frederic ZINGG [19:34 Uhr]
That would be a Graph revolution !

Jan Biedermann [19:34 Uhr]
yes, looks like that
lets sleep over it
whoa, i am thrilled, thats so freaking brilliant, so easy to implement
i throw away most of isomorfeus-record probably, just keeping the record class and the rest will just wrap the graph thing
so a scope is just the same as a graph, but without the edges, but that needs more thinking

We will have 4 basic classes:
```ruby
class LucidDataGraph < Isomorfeus::DataGraph
class LucidCollection < Isomorfeus::Collection 
class LucidNode < Isomorfeus::Node 
class LucidEdge < Isomorfeus::Edge
```

### Node
- has properties
- has edges

### Edge
- has properties
- has 2 nodes

### Graph
- has nodes
- has edges

```ruby
class MyGraph < LucidDataGraph::Base
  requires User, :id
  requires Organization, :id
  # maybe like this
  requires :user_id, User, :id

  # execute this block to get the graph, result is a array of root_node, nodes and edges
  query do
    # query for graph
    # refers to
    user_id
    organization_id 
    
    # example
    root, nodes, edges = Neo4j.something_whatever(user_id)
    [root, nodes, edges]
  end
  
  include_graph(:yet_another_graph) { YetAnotherGraph.fetch(user_id: user_id) }
  include_node(:action) { Action.find(user_id) }
  include_collection(:my_collection) { Indicator.all } 
  
  # tree
  include_graph :example_graph do
    include_graph :graph_example do
     include_node ...
     include_collection ...
     include_graph ...
    end
    include_collection :collection_example do
      # bla bla
    end
  end
end

# Usage
my_graph = MyGraph.promise_fetch(user_id: 1, organization_id: 2)
my_graph = MyGraph.fetch(user_id: 1, organization_id: 2)

my_graph.nodes
my_graph.edges

my_graph.action_nodes # nodes of class Action
my_graph.action_link_edges # edges fo class ActionLink

my_graph.walk do |node|
  # some code
end

my_graph.delete_node(node)
my_graph.delete_edge(edge)

my_graph.add_node(existing_node, new_node) # node is added to graph and linked to existing node
my_graph.add_edge(node1, node2) # same as link_nodes?, returns edge
```
### Collection
- has nodes (of same class?)
- maybe different accessors than Graph?