# Agent Tool Use

A key defining feature of agents is the ability to use tools to interact
with the environment around it. Interaction can include gathering information
from external sources or triggering actions.

With respect to software agents, the environment does not necessarily refer to
a physical environment or the entire world. Rather, it often  refers to the
host computer or a set of remote services like reservation systems, knowledge
bases, e-commerce platforms.

An agent uses some kind of program logic to automatically decide which tools to
use and how to call them. In the case of AI agents, we use language models as
the decision mechanism.

In workflows, we can expose tools to language models through *Chat* and
*Structured* nodes. *Agent* nodes supply a set of tools, along with other
parameters that are relevant to the specific subtask.

> [!note]
> We can also invoke tools manually, which we'll explore later in this series.

In this example, we will create simple weather agents using live weather
services over the Internet.

## Tool Providers

AI applications can implement and expose tools directly to language models.
However, translating between program functions to tool calls, invoking
implementations then transforming results can be tedious and error prone.

Instead, modern agentic systems use tools via a [Model Context
Protocol](https://modelcontextprotocol.io/) interoperability layer. AI
applications employ client libraries to connect to MCP servers.

MCP servers bundle related tools and provide a model/language agnostic
interface. They can be run locally or hosted by remote services. Client
applications can connect to them through a local STDIO transport, or over an
HTTP connection to internal network resources or to the Internet.

A wide variety of existing MCP servers can be found online[^mcp-lists]. The
majority of them are focused on wrapping a particular application or service
but many general-purpose utility-centric servers exist.

[^mcp-lists]: Some MCP server directories:
  https://github.com/modelcontextprotocol/servers
  https://mcpservers.com/
  https://mcpindex.net/en
  https://mcpserverdirectory.org/

![tool-tab](../assets/2026-02-27_15-13.png)

In aerie, tool providers are managed from the Tool tab.

![add-tools](../assets/2026-02-27_15-15.png)

You can create or import tool providers using the buttons at the top.

> [!tip]
> There are many tool provider configurations in `examples/tools/nix` that
> might be of use. Use the import button to add them.

**STDIO servers** are local executables that are launched and closed with the host
application. Multiple copies in different applications are independent
instances, but may use shared files or services. For instance, most database
MCP servers would connect to a running database engine, rather than launching
an embedded database instance.

**HTTP servers** are typically remote services hosted by a SaaS company or
cloud platform. You will need individual credentials to use these services,
usually in the form of an API key.

![edit provider](../assets/2026-02-27_15-31.png)

Select the provider from the list to edit its configuration.

![provider export](../assets/2026-02-27_15-34.png)

Using the context menu on a provider you can remove or export the provider
settings.

> [!warning]
> Do not include API keys, passwords and other personal information in the tool
> provider configuration since those will be included in the export. Set
> environment variables and reference them in the configuration.
>
> In a sensitive environment or with high-value credentials, do not set
> environment variables globally. Rather, use a secrets manager to decrypt them
> from a vault and set them only for the process.

![inspect tool](../assets/2026-02-27_15-32.png)

Select one of its tools to inspect its schema.

### Weather Tools

For these example workflows, we will fetch weather data from [open-meteo](https://open-meteo.com/), since it does not require API keys.
Since there is no official MCP server, we will use a third-party server: [MCP
Weather Server](https://github.com/isdaniel/mcp_weather_server).

In the Tools tab, import `examples/tools/nix/open-meteo.mcp`. By default this
will use the [nix](https://nixos.org/) package manager to load and run
[uvx](https://docs.astral.sh/uv/guides/tools/). Alternatively, you can invoke
`uvx` directly with the sole argument `mcp_weather_server`.

> [!tip]
> For other capabilities, explore other included example tools like tavily
> for web search (requires an account) or qdrant for vector indexing/search.

## Weather Chat

When an agent supplies tools to a *Chat* node, the language model must decide
if a tool is necessary to complete a particular request. If it is, it must also
decide which tool to call and what arguments to pass to it.

The results of the tool call are sent back to the model for a follow-up request
to interpret the results. This generally happens behind the scenes
automatically. Based on the results, the model might decide to call additional
tools or finish its response to the user.

For example, in planning a short trip for a user, an LLM might first look
up the current date, search for activities and events in a certain city, then
check the weather for that city to ensure that conditions will be favorable.

> [!note]
> The ability to break down a prompt into distinct steps and execute them in
> sequence largely depends on the model's complexity and training. There is no
> guarantee the model will complete the task on its own. Codifying these steps
> is the primary use case of workflows.

![weather-agent](../assets/2026-03-02_16-11.png)

For the workflow, we'll only focus on checking the weather. Let's start with
current conditions.

Create a new workflow and update the Agent node's system message, replacing the
blank with your city:

> You are a personal assistant for someone living in ______

Disconnect the `prompt` input of the *Chat* node and override it with a
question requiring knowledge of the current weather.

Even though we added tool providers to the application, earlier, we need to
tell individual agents which tools they are allowed to use.

Add *Tools &rsaquo; Select Tools* and check `get_current_weather` under
open-meteo. Wire it into the Agent node.

> [!tip]
> You can select other tools too to check whether the language model can select
> the correct one on its own.

![current weather](../assets/2026-03-04_19-06.png)

Add a *Preview* node and **run** the workflow.

Between the user's question and the final answer, there are extra messages. The
LLM first responds in JSON, with parameters for a tool call. It does not call
the tool directly, by itself. Rather the host application is responsible for
calling the tool and supplying the results back to the LLM, which we can see as
the follow-up message.

This isolates the responsibility of dealing with third-party accounts,
permissions, security, etc away from the LLM. All it needs to deal with is
language and logic.

### Message History

If the *Chat* node extends the conversation, then all these messages will
appear directly in the history. We might not necessarily want to see these
extra messages.

![extend history](../assets/2026-03-04_19-20.png)

One option is to take only the user prompt and final response and add them manually using
*History &rsaquo; Extend History*.

![extended results](../assets/2026-03-04_19-24.png)

The resulting session is now very simple and clean. However, we lose all the
intermediate information that was used to arrive at the conclusion.

![side chat](../assets/2026-03-04_19-27.png)

An alternative that preserves the data without cluttering the session is to use
*History &rsaquo; Side Chat*. The wiring is less complex than using an Extend
History node.

| collapsed | expanded |
| --------- | ---------|
| ![side results 1](../assets/2026-03-04_19-28.png) | ![side results 2](../assets/2026-03-04_19-32.png) |

The chat view still shows just the first and last messages by default, but now
the intermediate data is accessible from the expanding "details" section

> [!tip]
> Once you are satisfied with the workflow, remember to reconnect the `input`
> pin of the *Start* node to the *Chat* node.

## Multi-step

So far so good, but what about getting forecasts for upcoming days?

open-meteo has `get_weather_details` that can return hourly forecasts over the
next day. To get something further out, we'll need to use
`get_weather_byDateTimeRange`.

The latter call requires knowing the current date and time to calculate a range
in the future (API does not provide historical data). That might seem
trivial at first glance, however language models have no information about the
current state of the world, including the current date or time.

Fortunately, the weather MCP server provides `get_current_datetime` which the
agent can call before checking the forecast (however, it does not include
day-of-week labels). 

> [!tip]
> *Transform JSON* can also inject
> [date-time](https://gedenkt.at/jaq/manual/#date-time) information into a
> request, though zone handling is limited.

![multi-step-good](../assets/2026-03-05_14-31.png)

When a language model behaves as expected, it queries the current data before
fetching the forecast and the overall workflow succeeds.

![multi-step-fail](../assets/2026-03-05_15-12.png)

On the other hand, some smaller models that are capable of planning or using
tools may refuse to do both in the simultaneously.

Even if you explain the steps using instructions, they will still fail to call
the correct (or any) tool. In many cases, they will hallucinate the current
date or even the entire forecast, rather than failing in an obvious manner
(i.e. refusing to generate an incorrect answer or returning an error response).

> [!important]
> You cannot rely on a successful *Chat* response to determine that the model has
> actually executed the necessary steps. When it matters, you will need to
> check the message history using another agent or conditional logic.

The more tools an agent has to choose from, the more potential for it to get
confused. A universal catch-all agent using a small model to route between
dozens of tools is likely to fail or hallucinate frequently.

## Structured

Rather than a general purpose chat agent, if the specific purpose of a workflow
is known, we can specify a sequence of steps to complete the task. We can also
be more selective about the tools exposed to an agent.

> [!tip]
> You can use language models to route general prompts to task-specific
> branches within a workflow or route between workflows. See the examples and
> tutorials for more information.

Let's assume that we know answering a prompt requires knowing the current
date for a location and the weather forecast.

With that knowledge, we can break down the workflow into two phases:

1. getting the current time for the city
2. calculating a future date range
3. getting the forecast
4. answering the original prompt

![extract zone](../assets/2026-03-06_15-57.png)

To get the current time for step 1, we use language model to extract the zone
in much the same way we generated data from a schema in the previous chapter:
using the *Structured* node.

Instead of passing in a schema, we pass in an agent that has
tools. The LLM will understand that it has to find a city in the input and
infer the time zone.

> [!note]
> In fact, in structured generation, the schema is translated into a `submit`
> tool for the model to call.

![invoke tool](../assets/2026-03-06_16-02.png)

Unlike the Chat node, the Structured does not automatically call the tool ---
it only returns the tool name and arguments. To call the tool in a workflow,
use *Tools &rsaquo; Invoke Tool*.

![final chat](../assets/2026-03-06_17-09.png)

With the results in hand, we have several options for sending the date-time to
the LLM for additional steps. One option is to emulate the prompt/tool
call/tool results loop used by the Chat node by simply passing the conversation
to a new agent.

![range step](../assets/2026-03-27_16-47.png)

If we determine, during testing that the model does not perform steps 2 & 3
reliably, we can add them to the workflow similarly to the first step. Here,
we've used a model to calculate the date range as a structured object, leaving
the forecast call to the *Chat* node.

## Conclusion

In this article we've developed some contrived examples to demonstrate basic
tool integration.

While these are too narrow in scope for a general-purpose chat bot, workflows
are a perfect fit for specialist tasks. Larger systems can be built by
composing smaller workflows.

In the following articles we will explore creating more complex workflows to
extract and transform data from natural language texts.
