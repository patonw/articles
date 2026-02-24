---
outline:
- What is aerie
  - agentic workflow engine
  - On AI agents
    - simply LLM-driven systems that operate autonomously in a complex environment
    - Independent of human supervision
    - Interacts with the environment using tools
  - Workflows on the other hand, define task-specific procedures
    - In general can be built by programming or visual tools
    - Implicit or explicit use of a call graph
    - Divided into steps or nodes that execute a single subtask
    - Nodes connected to other nodes with input and output edges
    - Data flows in one direction along an edge
    - Workflow finishes when no more nodes are left to run
  - aerie is a visual tool that uses a nodes and wires to represent workflows
    - Provides a base set of nodes for data handling and control flow
    - Key nodes for interacting with LLMs and tools
    - Supports control flow branching and workflow chaining
      - Can break up complex tasks and route between workflows dynamically
      - Can iterate over lists of data to apply repetitive procedures on items
    - nodes to guides and constrains LLMs to ensure desired behavior
    - Editor supports incremental execution to speed up development
      - Don't need to rebuild and restart after every run
      - Can pick individual nodes to rerun
      - Can attach previews and outputs to internal nodes for debugging
    - Also has chat sessions with branching conversations
      - Can visualize entire session tree
      - Chat tab renders markdown and mermaid charts
      - Can launch workflows from chat tab
  - Do not need programming experience
    - Assumes technical background however
    - Should be familiar with JSON data format, command line programs, etc.
- Why use it
  - Current agentic frameworks just throw a bunch of tools at an LLM inside an execution framework
    - LLM decides which tool to call from a large set of unrelated options
      - Must use conversation context, instructions and latest prompt to infer what the user wants
      - Tool results are sent back in the conversation, whether success or failure
      - LLM must decide whether success conditions have been met to respond to the user
      - Or it can decide to try again, calling different tools or the same tool with different parameters
    - Complex procedures theoretically possible
      - e.g. Pull headlines -> identify companies -> lookup info -> update database -> write a report
    - In practice not feasible with smaller models
    - Larger models capable in many instances, but can easily get stuck in nonsensical loops
    - Otherwise, must write programs against multiple SDKs
  - Asking LLM to handle simple things on medium to large pieces of data risks hallucinations
    - Simple reformatting can introduce subtle or unsubtle changes in meaning
    - Very inefficient use of compute, regardless
    - "Dumb" programs can easily handle things like document restructuring or generating table of contents
    - Sending inputs to LLM to invoke these tools is still wasteful
  - Uses for aerie
    - Visualize/demonstrate agentic techniques
      - Easy to show different ways to do RAG, grounding, etc visually
      - Makes communicating and teaching more intuitive
    - exploratory analysis
      - with incremental execution, you can experiment with different ways of slicing results
      - try out different tools in combination or parallel
    - prototyping
      - easy to sketch out concepts and re-wire them on-the-fly
      - can organize workflow into distinct areas and subgraphs to demarcate team responsibilities
    - batch processing
      - Can use command-line runners to invoke workflow against stored or streamed data
    - automatic bots
      - Can trigger workflow runners on events and callbacks
    - request routing
      - with workflow chaining, can define rules for invoking task-specific workflows
- How to get started
  - Binary builds not available currently
  - Requires building from source using the [nix](https://nixos.org/) tool
  - See [manual](https://patonw.github.io/refoliate/aerie/user_start.html) for details
  - On first start, shows a basic workflow for a standard chat bot
  - Use the Import button from the command palette to open workflows in the `tutorial` folder
  - Right click on empty space to add nodes
  - Question key to see shortcuts
  - Import tools in the Tools tab from `example/tools/nix` folder
---

# Introducing Aerie

The AI landscape is evolving at unprecedented speed with new breakthroughs every few weeks.
While the capabilities of LLMs and other generative models is rapidly expanding one vital area
has been relatively stagnant: user agency. Without any programming expertise, we can already
create AI agents and teams of agents by providing tools and instructions. Though, the degree to which
they can follow a particular sequence depends primarily on the complexity of the model.

Software agents have three main characteristics. First, they act
independently without human supervision on behalf of the user. This may be triggered
by user prompting or external cues and events.
Second, they can interact with an environment using tools which may be libraries, remote APIs
or other agents.
Third, they can make dynamic decisions based on data and their internal logic.
AI agents extend on this last part by using generative language models.
This is very powerful because a vast body of logic has been encoded in the written material
used to train the models. However, novel problems might not match standard solutions.

> [!todo]
  bridge

Branching and looping logic introduces even more opportunity for
highly independent instruction-centric agents to deviate from the desired path.
Patterns of organizing agents into teams of specialized workers and managers can help, but
oftentimes the outcome depends on the managers' ability to select the correct worker, which
in turn depends on the specificity of agent descriptions with respect to the task prompt.

Trying to accomplish modestly complex tasks with smaller models can become an exercise in aggravation.
The mismatch we've encountered is giving too much independence to agents under the premise that
instructions and fine tuning can solve any problem. The truth is, they might be able to solve
any problem occasionally, but not reliably.

We need to reframe the problem from having LLM-based agents solve a task for us to using LLM-agents
while solving a task. That is, the LLM becomes a small but critical step in a series of steps.
Most steps will involve deterministic data processing rather than generative inferencing.
The steps are connected with one step's output becoming the input for one or more dependent steps.
A step may depend on zero or more other steps. The total collection of all steps and dependenies
forms a graph.

Many programmatic frameworks for building workflows are becoming popular. However, using them
to build workflows requires you to not only learn the particular language but also the conceptual
model of the framework. The understandability and maintainability of the resulting workflows
is dependent on your adherence to best practices and design patterns. While anyone can learn
these techniques, by the time most people realize they are needed, the workflows are already
irrecoverably incomprehensible.

With graphical tools, even an untrained eye can see the difference between a well organized
workflow and a convoluted tangle of wires. Furthermore, visual representation is good
for communication and educating colleagues about your workflow. With visual tools you can more
easily reorganize and modify existing workflows. Finally, visual tools are great for rapid prototyping
and exploratory analysis.

Enter Aerie, a agentic workflow engine and visual editor. Agents and other steps are represented
as nodes in a graph. Each node defines input and output pins which can be connected to other nodes.
Aside from agents, there are nodes for JSON manipulation, templating, control flow and conversation
management. Furthermore, related nodes can be grouped into subgraphs. Workflows can iterate over
data collections and perform routing internally or external workflows.

The visual editor provides iterative execution which is very helpful for debugging and development.
Additionally, it provides a chat interface with branching sessions to allow you to compare
different approaches. Workflows can be chat-centric or input/output focused. You can set an
input schema to the workflow to help other workflows or applications call it.
