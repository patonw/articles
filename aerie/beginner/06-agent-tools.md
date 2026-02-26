# Agent Tool Use

A key defining feature of AI agents is the ability to use tools to retrieve
external information or affect the environment around it. In this context, the
environment is not necessarily physical. Most often, it refers to either the
host computer or a set of remote services like reservation systems, knowledge
bases, e-commerce platforms.

In workflows, we can use tools through Chat and Structured nodes. Agent nodes
supply a set of tools, along with other parameters that are relevant to the
specific subtask. We can also invoke tools directly, which we'll explore later
in this series. For now, let's create simple weather agents.

## Tool Providers

Instead of providing individual tools directly to the application, the primary
unit of tool distribution in MCP is an MCP server which bundles related tools
in a single interface. This can be a local executable or a remote service.

A wide variety of existing MCP servers can be found online[^mcp-lists]. The majority of
them are focused on wrapping a particular application or service but many
general-purpose utility-centric servers exist.

![tool-tab](../assets/2026-02-27_15-13.png)

In aerie, tool providers are managed from the Tool tab.

![add-tools](../assets/2026-02-27_15-15.png)

You can create or import tool providers using the buttons at the top.

> [!tip]
> There are many tool provider configurations in `examples/tools/nix` that
> might be of use. Use the import button to add them.

> [!note]
> STDIO servers are local executables that are launched and closed with the host
> application. Multiple copies in different applications are independent
> instances, but may use shared files or services. For instance, most database
> MCP servers would connect to a running database engine, rather than launching
> an embedded database instance.

> [!note]
> HTTP servers are typically remote services provided by a SaaS company or
> cloud platform. You will need individual credentials to use these services,
> usually in the form of an API key.

![edit provider](../assets/2026-02-27_15-31.png)

Select the provider from the list to edit its configuration.

> [!warning]
> Do not include API keys, passwords and other personal information in the tool
> provider configuration. Set environment variables and reference them in the
> configuration.

![provider export](../assets/2026-02-27_15-34.png)

A provider's context menu allows you to remove or export the provider.

![inspect tool](../assets/2026-02-27_15-32.png)

Select one of its tools to inspect its schema.

### Weather Tools

For these examples, we'll focus on the weather aspect of workflows and only use
open-meteo, since it does not require API keys.

In the Tools tab, import `examples/tools/nix/open-meteo.mcp`.

> [!tip]
> For other capabilities, experiment with other example tools like tavily
> for web search, but requires an account.

## Weather Chat

When an agent supplies tools to a Chat node, the LLM will decide whether using
a tool is necessary, which tool to call and what arguments to pass to it. The
results of the tool call are sent back to the LLM for a second request to
interpret the results. This happens behind the scenes automatically and can
repeat multiple times until the LLM decides to stop calling tools.

For instance, the in planning a short trip for a user, the LLM might first look
up the current date, search for activities and events in a certain city, then
check the weather for that city to ensure that conditions will be favorable.

> [!note]
> The ability to break down a prompt into distinct steps and execute them in
> sequence largely depends on the model's complexity and training. There is no
> guarantee the model will complete the task on its own.

![weather-agent](../assets/2026-03-02_16-11.png)

Let's start with current conditions.
Create a new workflow and update the Agent node's system message, replacing the
blank with your city:

> You are a personal assistant for someone living in ______

Disconnect the prompt and override it with a question requiring knowledge of the current weather.

Add *Tools &rsaquo; Select Tools* and check `get_current_weather` under
open-meteo. You can select other tools too to see if your LLM can pick the
right one on its own. Wire it into the Agent node.

Set a prompt only requiring current conditions like:

> Are the conditions good for paddle-boarding, right now?

![current weather](../assets/2026-03-04_19-06.png)

Add a Preview and run.

Between the user's question and the final answer, there are extra messages. The
LLM first responds in JSON, with parameters for a tool call. It does not call
the tool directly, by itself. Rather the host application is responsible for
calling the tool and supplying the results back to the LLM, which we can see as
the follow-up message.

This isolates the responsibility of dealing with third-party accounts,
permissions, security, etc away from the LLM. All it needs to deal with is
language and logic.

If the Chat node extends the conversation, then all these messages will appear
directly in the chat history. We might not necessarily want to see these extra
messages.

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

## Multi-step

So far so good, but what about forecasts? open-meteo has `get_weather_details`
that can return hourly forecasts over the next day. To get something further
out, we'll need to use `get_weather_byDateTimeRange`.

This requires the current date and time. That might seem trivial at first
glance, but remember that LLMs have no information about the current state of
the world. In this example, let's have the agent use `get_current_datetime`
before checking the forecast.

![multi-step-good](../assets/2026-03-05_14-31.png)

When things go right, the agent queries the current data before fetching the
forecast.

![multi-step-fail](../assets/2026-03-05_15-12.png)

On the other hand, some smaller models that are capable of planning and using
tools refuse to do both in the same step. Even if you explain the steps using
instructions, they will still fail to call the right/any tool. In many cases,
they will hallucinate the current date.

This gets worse, the more tools an agent has to choose from. A universal
catch-all agent using a small model to route between dozens of tools is likely
to fail most of the time.

## Structured

If we know the general subject of a prompt, we can be more selective
about the tools exposed to an agent. If the underlying purpose of a prompt is
also known, then we can specify a sequence of steps to complete the task or at
least prepare the primary agent for success.

> [!tip]
> Using a model to select between several possible agents is known as routing.
> You can route within a workflow or route between workflows. See the examples
> and tutorials for more information.

Let's assume that decision has already been handled and that we know answering
the prompt requires knowing the current date for a location and the weather
forecast.

With that knowledge, we can break down the workflow into two phases:

- getting the current time for the city
- answering the original prompt

![extract zone](../assets/2026-03-06_15-57.png)

To get the current time, we use an LLM to extract the zone in much the same way
we generated data from a schema in the previous chapter: using the Structured node.
Instead of passing in a schema, we pass in an agent that has tools. The LLM
will understand that it has to find a city in the input and infer the time
zone.

> [!note]
> In fact, in structured generation, the schema is translated into a `submit`
> tool for the model to call.

![invoke tool](../assets/2026-03-06_16-02.png)

Unlike the Chat node, the Structured does not automatically call the tool ---
it only returns the tool name and arguments. To call the tool in a workflow,
use *Tools &rsaquo; Invoke Tool*.

![final chat](../assets/2026-03-06_17-09.png)

With the results in hand, we have several options for sending the date-time to the LLM.
One option is to emulate the prompt/tool call/tool results loop used by the
Chat node by simply passing the conversation to a new agent.

## Conclusion

This is a contrived example to demonstrate basic tool integration.
While not suited for a general-purpose chat bot, a workflow like this would be
appropriate for handling well defined tasks from predictable sources.

We will explore that type of use case in more depth to create workflows for
extracting and transforming data from natural language texts.
