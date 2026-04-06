# Aerie: First Flight

## Introduction

### Why use workflows?

You hire a brilliant intern and give them unrestricted access to your company's
systems with high-level instructions to complete a complex task. They do a
reasonably good job without breaking anything important, the first time. Should
it be a surprise when a minor misunderstanding of the next task cascades into
complete disaster? Yet this is commonly how we manage AI agents. For all their
impressive capabilities, language models do not learn from experience as you
"engineer" a prompt [^1].

[^1]: Fine tuning models is a different matter, with steep data and resource
    requirements.

Software agents are systems that make decisions and operate independently from
human supervision on behalf of users. AI agents replace deterministic program
logic with language models. These models, however, are inherently
probabilistic. The more autonomy we give them, the greater the opportunity for
surprises.

No matter how well-tuned prompts are during development, there are
uncountably many ways for things to go wrong in the wild. The more detailed you
make the prompt to account for pitfalls, the less attention the model can pay
to the core task. Furthermore, failure-retry loops can balloon the context,
confusing the model even further.

AI powered workflows provide a more reliable alternative to purely
agent-driven systems. A workflow breaks a task down to discrete, well-defined
steps. AI plays a specific but limited role in some of those steps allowing it
to concentrate on what it excels at without extraneous distractions.

### What is Aerie?

Aerie[^aerie] is a graphical tool for building agentic workflows. Programming expertise
is helpful, but not necessary. In this instance graphical is an overloaded term:
aside from the user interface of the visual editor, workflows are structured as
node graphs. Each node represents agents, data transformations, decisions, etc.
Outputs of a node can be connected to inputs of other nodes.
Data flows predictably from one node to the next.

With this visual approach it's easier to build, debug, explain and iterate on
workflows -- making aerie appropriate for prototyping and collaboration.

[^aerie]: A nest of a bird of prey perched high on a cliff or tree top.

![graph legend](../assets/2026-04-06_14-48.png)

## Setup

Aerie can be run from [source](https://github.com/patonw/aerie) or a binary
AppImage available on the
[releases page](https://github.com/patonw/aerie/releases).

The AppImage can be run directly under Linux without installation. However, you
will usually need to set the correct permissions after downloading the file.

```bash
$ chmod +rx aerie-x86_64.AppImage
```

It can also be run under Windows with [WSL](https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps).

Building and running from source is recommended, however. The development stack
provides a uniform and predictable environment for the application. On the
other hand, it requires far more disk space and time for the initial start. For
instructions on building the source, see the [Development
Guide](https://patonw.github.io/aerie/dev_start.html).

You can also install from source using the [nix tool](https://nixos.org/download/):
[Installation](https://patonw.github.io/aerie/user_start.html#installation).

## Getting started

To get a small taste of the potential of this approach, we will start by
building a trivial workflow. It will pass a user's prompt and conversation
history to an LLM and then rewrite its response as a haiku. Almost every modern
language model can handle this in a single step, but we'll use two agents for
didactic purposes.

In later articles we'll explore topics like data extraction, tool use and
iteration.

![create button](../assets/2026-02-18_22-29.png)

Click the Create button on the command palette to create a new workflow with
default nodes. Rather than an empty document, it will contain a basic chat
agent which you can choose to integrate into your workflow or discard. We'll do
the former this time.

![finish node](../assets/2026-02-18_22-41.png)

First, disconnect the `conversation` pin on the Finish node, for now.  You can
do this by right-clicking on the wire itself or the pin on either source or
destination node.

Normally, this would send the completed conversation of the
workflow to the chat session, viewable in the Chat tab. In the meantime, we'll
be working only in the workflow editor.

> [!NOTE]
> Pins on the right side of a node are output pins while pins on the left side
> are inputs. Information flows in only one direction along a wire from the
> output pin of a source node to an input pin of the destination node.

### Normal Agent

![agent wires](../assets/2026-02-18_22-38_1.png)

Next, we'll use the existing agent to generate a normal response.
Disconnect the `temperature` and `input` wires between the *Start* and *Agent* nodes.

The *Start* node is the entry point into the workflow, gathering settings and
inputs from the execution environment and exposing them to the other nodes in
the workflow. These values are only available from the *Start* node.

![agent settings](../assets/2026-02-18_22-42.png)

*Agent* nodes define parameters for invoking LLMs via Chat and Structured
nodes. An *Agent* node does not generate content by itself. Rather it holds
settings to differentiate itself from other agents and can be re-used in
different stages of the workflow by content generating nodes.

Set the LLM model using the format `{provider}/{model}`. Examples:
`ollama/devstral:latest` or
[`openrouter/openrouter/free`](https://openrouter.ai/openrouter/free). Most
providers will have a list or database of models they provide (e.g.
https://openrouter.ai/models & https://docs.mistral.ai/getting-started/models).

> [!important]
> Local providers like Ollama don't require authentication, but services like
> OpenRouter, Anthropic, etc usually require an API key. See [API
> Keys](#api-keys) for details.

Set the temperature low (~0.25).

> [!NOTE]
> The temperature can be set between 0.0 and 1.0. It controls how words
> are selected from a range of possibilities during generation. It is loosely
> correlated with creativity. Higher temperatures mean more improbable outputs,
> while lower temperatures tend to produce drier generic responses.

![chat node](../assets/2026-02-24_14-04.png)

Now that the agent is configured let's take a look at the *Chat* node. This is the node
that actually interacts with the language model provider to generate content.

It takes configuration values from an *Agent* node and optionally a
conversation history -- an ongoing list of user prompts and agent responses.
In this instance, the conversation is supplied by the *Start* node, since this
is the first *Chat* in our workflow.

Finally, it takes a prompt, which you can supply from a text value like the
`input` pin of the *Start* node as we saw earlier with the default workflow. In
this instance, however, leave the pin unwired and type the text prompt directly
into the node.

### Saving

![autosave](../assets/2026-02-18_22-32.png)

Before we continue, it's a good idea to enable `autosave` in the Settings tab.
This will write any changes you make to disk automatically. Alternatively you
will need to click the Save button in the command palette manually for all
changed workflows.

> [!warning]
> If there are unsaved changes to workflows other than the one displayed, they
> may be lost. The app will not warn about discarding unsaved changes when
> exiting.

### Previews

![create preview](../assets/2026-02-24_14-12.png)

So far we've modified existing nodes, but now let's create a new node for
examining wire values during a run. The *Preview* node will show intermediate
values when the workflow is run from the editor but has no effect otherwise.

> [!note]
> The *Preview* node can accept any wire value and will change its display
> format according to the type.

Right click on the canvas in the area you want the new node to appear. A
context menu appears with nodes that can be added to this graph. Select the
Preview item to create a new node.

### Running Workflows

![running workflow](../assets/2026-02-24_14-14.png)

Connect the `response` pin of the *Chat* node to the *Preview*'s input and **Run** the
workflow using the button in the command palette.

As the workflow runs, nodes that have finished will be marked with a green
check.

Nodes that are actively running will have a spinning circle in the corner.

![finished workflow](../assets/2026-02-24_14-18.png)

Once the workflow has run, the *Preview* node will show a standard response to
our prompt.

### Poetic Agent

![agent two](../assets/2026-02-24_14-28.png)

Now that We have a first agent generating normal (boring) responses, it's time
to create a second agent to generate poetry. This has a distinct purpose and
personality from the previous agent, so we'll configure it with different
settings.

Create a second agent from the context menu *LLM &rsaquo; Agent*.

Connect it to the first agent. It will take configuration values from the first
agent unless you override them.

> [!note]
> Different languages will have differing proficiencies at various tasks. Some
> will focus more on generating program code while others will be better at
> writing long-form text. It can be beneficial to experiment with different
> combinations in a workflow.

Override the temperature and set it higher (>0.75).

You can also override the system message (currently blank) to add personality
or add specific instructions for the current task. Instructions can vary
between formatting requirements, strategies for executing a task or admonitions
about avoiding particular pitfalls.

We won't provide any instructions this time. However, let's give the agent a
role to play, to impart some flavor on the generated result.

![chat two](../assets/2026-02-24_14-40.png)

Create a second *LLM &rsaquo; Chat* node and connect it to the new agent.

Since we are asking it to act on prior responses, you will need to connect the
conversation to the previous *Chat* node **NOT** the *Start* node.

> [!important]
> Connecting it to the *Start* node would create a parallel conversation that
> omits the previous agent's response.

Finally, connect it to another Preview node so we can compare the results
side-by-side.

## Incremental Execution

Notice that the new nodes do not have status indicators, yet, in contrast to the
old nodes. This shows which nodes will be executed during an incremental
run. Other nodes with  will be skipped, saving time and avoiding
extra API fees. This allows you to quickly try variations on node parameters or
different combinations of nodes without redundant work.

> [!tip]
> Selected nodes and the node under the cursor are also re-executed during an
> incremental run.

You can trigger an incremental run with the shortcut `Ctrl+R` (see shortcuts
with the `?` key).

> [!note]
> The Run button in the command palette will trigger a full re-run of every
> node in the workflow.

![run two](../assets/2026-02-24_14-47.png)

Notice that the "normal" *Chat* node does not rerun incrementally (assuming you
haven't changed, selected or hovered over it).

Try changing the second prompt (e.g. haiku &rarr; sonnet) and notice the status
indicator disappears.

Another incremental run should only re-execute that node.

If you change the second Agent node, one of two things will happen, depending
on whether the `cascade` setting is enabled. When `cascade` is enabled, a
status reset will propagate from a node to its children and all its
descendants.

> [!tip]
> Without `cascade` only the Agent node's status is cleared. To have the Chat
> node re-run incrementally, you will need to hover over or select it.


## Chat Sessions

We've been using the Workflow tab exclusively so far. If you go to the Chat
tab, notice that none of the messages appear. That's because the workflow
hasn't added anything to the session. The fix is simple: connect the last Chat
node to the Finish node.

Why didn't we do this from the beginning? Try another incremental run. You
should get an error about unrelated histories. This is because the
incremental state has an old copy of the conversation.

> [!note]
> Internally, replacing it with the current conversation would invalidate the
> entire workflow state. Rewinding and using the stale conversation is not
> permitted, however, since workflows are not allowed to make destructive
> changes to the session. They can only add content, but ignoring new messages
> and overwriting them with new ones would remove existing history from the
> session.

This restriction only applies to workflows. From the Session tab you can perform
various changes to the conversation history.

> [!important]
> [Why aren't my chats saved?](#set-active-session)

## Conclusion

While what we've seen here isn't particularly groundbreaking or useful, now
you should be comfortable with using the editor to build workflows. Next, we'll
explore generating and manipulating structured data, before moving on to tools,
subgraphs and iteration.

## Troubleshooting

### Workflow gets stuck on Chat node

#### API Keys

API keys specific for each provider must be defined in the
[environment](https://github.com/0xPlaygrounds/rig/blob/main/skills/rig/references/providers.md).

Unfortunately, [rig](https://rig.rs/) the underlying library to connect to AI
providers usually halts the execution thread instead of triggering a
recoverable error.

Changes to the environment will not take effect until the application restarts.

> [!warning]
> While it is common practice to use system/account-wide environment variables,
> there are security concerns stemming from this. One alternative is to use
> [direnv](https://direnv.net/) to limit its scope by directory. However, this
> requires API key to be stored as plain text.
>
> A more secure option is to use a password manager/vault application with
> console integration, like [Bitwarden](https://bitwarden.com),
> [vault](https://www.hashicorp.com/en/products/vault),
> [pass](https://www.passwordstore.org/), etc. Some will allow you to launch
> applications with environment variables pulled from secure storage.

#### Enable streaming

In some cases, providers may actively generate a response, but the response
itself will be large, taking minutes to complete. Most providers support
streaming individual tokens, allowing you to see the response as it is
generated, rather than waiting for it to finish.

#### Change providers/models

Some providers have high latency or unreliable connections. If one does not
respond in a reasonable amount of time try another.

Be aware that some providers ([openrouter](https://openrouter.ai/) for
instance) proxy to other providers. Different models may run on different
providers.

Even on a single provider, models may be allocated different hardware resources
to handle different requirements or due to popularity.

### Workflow gets stuck elsewhere

#### Check console logs

This application is still under active development. Most errors will trigger an
error dialog, but some may cause the run to fail silently. The console may
provider warnings or other indication about what has failed.

### Can't edit node

#### Workflow is running or frozen

The workflow can't be edited while it is running. Wait for it to complete or
use the **Stop** button to interrupt it.

The editor can be frozen/unfrozen manually or while examining edit history.
This prevents unintended changes when browsing through the Undo stack.

To unfreeze the workflow, toggle the button on the control palette.

#### (Dis)connect input pins

Some fields can take values from controls on the node as well as input wires.

The controls will not be visible unless the wire is disconnected.

#### Toggle optional controls

Some node fields are optional. For example, fields that might override a
previous value will need to be enabled to be edited.

### Chat history disappears on restarting app

#### Set active session

By default no session is active. When no session is active (denoted by an
empty value in the session selection) chats are discarded when the app exits.
To save an ongoing chat, rename the session. The active session is reloaded
the next time you start the app.

