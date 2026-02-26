# Introducing Aerie

> [!note]
> This is a verbose justification for graphical workflow tools without any
> practical content. Start with the next article to dive right in.

The AI landscape is evolving at unprecedented speed with new breakthroughs
every few weeks. While the capabilities of LLMs and other generative models is
rapidly expanding one vital area has been relatively stagnant: user agency.
Without any programming expertise, we can already create AI agents and teams of
agents by providing tools and instructions. The degree to which they can follow
a particular sequence depends primarily on the complexity of the model. Agents
that seem reliable and predictable during development can behave in unexpected
and problematic ways after deployment.

## AI Agents

Software agents have three main characteristics. First, they act independently
without human supervision on behalf of the user. This may be triggered by user
prompting or external cues and events. Second, they can interact with an
environment using tools which may be libraries, remote APIs or other agents.
Third, they can make dynamic decisions based on data and their internal logic.
AI agents extend on this last part by using generative language models.

This can be quite powerful because a vast body of logic has been recorded in
the source material used to train the models. However, novel problems might not
match well to the common solutions encoded within these models.

Branching and looping logic introduces even more opportunity for highly
independent instruction-centric agents to deviate from the desired path when
carefully tuned instructions become lost in a growing sea of tangential or
misleading context.

Patterns of organizing agents into teams of specialized workers and managers
can help, but oftentimes the outcome depends on the managers' ability to select
the correct worker, which in turn depends on the specificity of agent
descriptions with respect to the task prompt.

Trying to accomplish modestly complex tasks with smaller models can become an
exercise in aggravation. One common problem stems from giving too much
independence to agents under the premise that wording instructions with just
the right prompt can solve any problem. However, prompt tuning only reveals
local optima which only yield predictable behavior for subsets of possible
inputs.

## Workflows

To circumvent these problems, we can employ more structured approaches:
workflows, for instance.

This subtly reframes the problem from using LLM-based agents to solve tasks for
us to using LLM-agents while solving a task. That is, instead of the LLM being
the key driver in finding the solution, the LLM becomes a small but critical
step in a series of well defined steps.

Rather than handing a model an assortment of tools and asking it to "go figure
it out yourself" we guide it in discrete steps with limited tools telling it
"use this tool first" then "use the output to call another tool".

The steps are connected with one step's output becoming the input for one or
more dependent steps. A step may depend on zero or more other steps. The total
collection of all steps and dependencies forms a graph.

## Programming vs. Design

Many software frameworks for building workflows are becoming popular. However,
using them to requires programming knowledge and also a conceptual familiarity
with the particular framework.

Also, how understandable or maintainable workflows built on these frameworks
are, over time, depends largely on your (and your team's) adherence to best
practices and design patterns. With graphical tools, even an untrained eye can
quickly spot the difference between well organized workflows and a convoluted
tangle of wires.

Furthermore, visual representation is good for communication and educating
colleagues about your workflow. With visual tools you can more easily
reorganize and modify existing workflows. Finally, visual tools are great for
rapid prototyping and exploratory analysis.

## Aerie

Enter Aerie: a agentic workflow engine and visual editor.

Agents and other steps are represented as nodes in a graph. Each node defines
input and output pins which can be connected to other nodes. Aside from agents,
there are nodes for JSON manipulation, templating, control flow and
conversation management. Furthermore, related nodes can be grouped into
subgraphs. Workflows can iterate over data collections and perform routing
internally or external workflows.

The visual editor provides iterative execution which is very helpful for
debugging and development. Additionally, it provides a chat interface with
branching sessions to allow you to compare different approaches. Workflows can
be chat-centric or input/output focused. You can set an input schema to the
workflow to help other workflows or applications call it.

This series will be focused on getting you comfortable with creating workflows
using contrived examples.
