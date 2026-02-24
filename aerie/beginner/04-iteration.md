# Subgraphs & Iteration

...continuing from the claims checking workflow.

Now that the checking agent is working, let's run it against every claim.
To do that, we'll need to wrap it in an Iterative Subgraph.

- A subgraph is a node that contains an internal set of nodes and edges
  - Similar to a workflow but only exists inside a workflow
  - Inputs and outputs are user defined
  - When run, a subgraph executes from start to finish before the parent workflow continues
  - Subgraphs can even contain other subgraphs
- An iterative subgraph is a special case that runs once for every element of a list input
  - Externally, the node takes list values as inputs
  - Internally, the subgraph operates on individual elements
  - i.e. The node in the workflow takes a list of text items, but inside the subgraph, Start exposes just a text value

- Add a Subgraph &rsaquo; Iterative node
- Double-click the icon to enter the subgraph implementation
- Notice that the `input` pin has changed from a square on the Subgraph node to a circle on the Start node
- Add a new agent input on the start node
- You can double-click the label to edit the name or reorder inputs

- Click on the parent workflow name in the command palette to exit the subgraph
- Notice that the subgraph node now has a new input for the agent
- Connect it to the claims checking Context node
- For now, connect the `input` pin to the individual unwrapped claim

- To move the schema and Structured nodes into the subgraph, we can use cut and paste
- Shift-click on each node and press your system's cut shortcut (`ctrl+x` for example)
- Double-click on the subgraph to enter it and press the paste shortcut

- The default output type is a text value which becomes a text list in the parent workflow
- We want to return JSON for this case though
- Double-click the `output` pin of the Finish node to start editing it
- Delete it
- Create a new JSON output and connect it to the Structured `data` output

- JSON values are dynamically typed at runtime and can be primitive types, objects or arrays
- The Structured node outputs an object
- The Subgraph node in the workflow actually emits a JSON array of objects
- The pin does not change since JSON objects and arrays are both considered JSON values

- Now that the subgraph works on a single element, we can actually iterate over the entire claims list
- Switch the Subgraph `input` to the unwrapped `.claims` list
- Run it again and notice the progress bar on the node
- Once it finishes, the Subgraph will output a list of all claims with their evidence

- You can enable `parallel` iteration, BUT
  - Be mindful of API limits when iterating, especially when using free LLMs
- It's a good practice to use rate limiting
  - To do that, we'll need to talk about tool use
  - Subject of next article
