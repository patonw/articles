# Subgraphs and Iteration

In the previous example we explored how to use an LLM to extract factual claims
and how to check an individual claim against the rest of the context.

To check all claims there are two options:
- Ask the LLM to check all claims in one shot
- Check each claim individually and combine the responses

In the first option, many LLMs end up skipping claims or mixing up evidence.
This is often as effective as asking someone to glance over the material and
use their intuition to "feel" if the claims are grounded. Reasoning models can
perform better in this regard by breaking down the list during reasoning, but
this still lacks rigor.

To check claims individually, however, we need to overcome a particular hurdle.
By design, each node in a workflow is executed at most, once per run. This ensures
workflows complete within a finite amount of time, bounded by the total number of nodes.

Rather than adding control structures analogous to for/while loops, workflows use a
special node that acts on entire lists: Iterative Subgraph.

From an outside perspective, this node takes a list as input and is executed
once during the run, producing a new list.
Internally, it repeats a subtask over every item in the list and gathers the
results into an output list.

You determine the subtask it performs on the list items by creating a nested
graph -- a subgraph.

Aerie supports two kinds of subgraphs: simple and iterative. Simple graphs do
little more than hold nodes to simplify the parent workflow. Even without
additional behavior they are useful for organization. Iterative subgraphs
execute their contents on each item of a list.

## Subgraphs

![subgraph node](../assets/2026-02-26_11-38.png)

There are some common rules governing all types of subgraph nodes.
To edit the contents of a subgraph, double-click the icon in the body of the node.

![subgraph controls](../assets/2026-02-26_11-41.png)

This will open the subgraph editor which has a modified control palette. The
top part shows the subgraph stack. Subgraphs can contain their own subgraphs.
Each button in the stack shows a different level in this hierarchy. Clicking on
one of switches the editor to the corresponding ancestor graph.

Inside the subgraphs, the editor contains a set of nodes and wires, including a Start and Finish node.

The inputs and outputs to the subgraph node are determined by the pins on its
internal Start and Finish nodes. You can customize these pins within the
subgraph editor, unlike the Start and Finish nodes of top-level workflows.


> [!important]
> During a workflow run, when a subgraph node is executed, the entirety of its
> contents is executed before the parent resumes. When a subgraph node is
> finished, none of its internal nodes will run in the future. The execution of
> nodes inside the subgraph does not interleave with nodes of the parent.

> [!note]
> At the moment, subgraphs do not run incrementally. Any changes inside the
> subgraph reset the entire node.

Continuing the claims checking example, let's create a *Subgraph &rsaquo;
Simple* node to hold the first agent. This isn't necessary for the small number
of nodes, but it will allow us to get familiar with the subgraph editor.

![selection](../assets/2026-02-26_14-07.png)

Select the nodes containing the agent, schema and structured output and copy them
into the subgraph.

![sub-input](../assets/2026-02-26_14-09.png)

The default text input can be wired directly into the prompt pin.

![output trash](../assets/2026-02-26_14-13.png)

The output needs to be JSON, however. We must replace the output. First
double-click on the label to edit the pin on the Finish node. Clicking on the
trash icon will remove this value.

![add output](../assets/2026-02-26_14-14.png)

Then add a JSON output using the `+new` button.

![simple-complete](../assets/2026-02-26_14-16.png)

Connect it to the Structured Output node to complete the subgraph.

![subgraph replace](../assets/2026-02-26_14-23.png)

Now we can replace the nodes in the parent with the subgraph, by rewiring the
upstream and downstream nodes. You can rename it by double clicking on the
title to document the purpose of the subgraph.

What did that buy us? Instead of a tangle of nodes near each other, we have a
single node that represents a logical unit of work. The agent and schema are
neatly hidden away.

![alternative](../assets/2026-02-26_14-34.png)

On the flip-side, if you want to compare and modify the agents, for instance,
now you have to navigate into a subgraph. Alternatively, you could add an input
pin for the agent and pass it in from the top-level workflow.

Deciding what to put inside the subgraph vs what to pass as inputs is a
balancing act that will change depending on the situation.

## Iteration

Iterative subgraphs operate on list items. This leads to changes in how inputs
and outputs are handled.


| Node | Subgraph |
| ---- | -------- |
| ![outside](../assets/2026-02-26_12-06.png) | ![inside](../assets/2026-02-26_12-02.png) | 


Inside the subgraph, the Start node exposes individual values
(i.e. text, message, number, etc). On the Iterative Subgraph node in the parent, however,
these are represented as lists. The parent sends in a list of text strings, for instance,
and the subgraph runs once for every text.

> [!note]
> You can distinguish between single item (circle) and list (square) pins by shape.

Similarly, the Finish node inside the subgraph can receive individual values
which the subgraph node collects and presents to the parent as a list of
values.

![create iterator](../assets/2026-02-26_14-38.png)

Create a *Subgraph &rsaquo; Iterative* node. Copy the agent, context, schema
and structured nodes from the workflow and paste them into the subgraph editor.
Connect the input to the Structured node.

Similarly to the Simple Subgraph, replace the text output pin with a JSON output.

![input doc](../assets/2026-02-26_14-46.png)

You may have noticed that the context is now blank. Add a new text field to the Start node
and rename it "document". Connect it to the context.

> [!tip]
> You could also reorder pins to minimize crossing wires if you wish. We'll
> leave them as is during this workflow, however.

Back in the parent workflow, we can connect the Wikipedia article to the `document` pin,
even though it is a single item, while the subgraph takes a list. In this
instance, the subgraph will broadcast the item into every iteration such that
all executions of the subgraph will see the same value for that pin.

![unwrap claims](../assets/2026-02-26_15-03.png)

On the other hand, the claims are currently wrapped inside JSON and automatic conversion isn't supported yet.
We can use a *JSON &rsaquo; Unwrap JSON* node, however. Changing the Transform
filter to `[ .claims[1] ]` will extract the second claim but place it inside a
new list. This allows us to test the single value as a list.

> [!tip]
> Developing the workflow against a single item saves a lot of time and API credits.
>
> Adjust the agent settings and run the workflow until you are satisfied that
> the new subgraph works correctly using only one or two list items before
> expanding it to the full list.

![progress](../assets/2026-02-26_15-11.png)

Once everything is in order, change the filter to just `.claims` to iterate over the whole list.
Now when you run the workflow, notice the progress bar on the Subgraph node tracks.

![done](../assets/2026-02-26_15-18.png)

Once it finishes, you should have a list of JSON values, or an error, depending
on how well the grounding agent behaves.

You might have to go back and adjust the agent settings again until it produces satisfactory results.

> [!caution]
> You may have noticed the `parallel` option on the Iterative Subgraph. This
> will speed up the workflow, but might cause issues with rate limiting. Hold
> off on using it until we cover rate-limiting via tools.

## Conclusion

With iteration in place, the claims checking workflow is complete. Given an
article, the workflow will systematically verify that the most important claims
are supported by citations in the text. More broadly, this pattern of
extracting, iterating then combining will be a useful building block for
solving many tasks.

However, there are still ways to improve this workflow. One issue is that its
results are only visible when running in the editor application. Another
problem can occur if we try to process larger collections: the workflow can
overwhelm the LLM provider and get blocked.

In the next installments, we'll see how to overcome these limitations by
rate limiting via tool calls and creating outputs.
