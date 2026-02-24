---
- integrates with MCP tools
- provides an extension mechanism understood by most LLMs
- wide variety of existing MCP servers available online
- easy to build custom servers with variety of languages
- potential far beyond popular uses
  - Can wrap any library of a language that has an MCP SDK

- tools managed from Tool tab
- tools grouped by tool providers (i.e. MCP servers)
- add, delete, import, export and edit tool providers
- can also examine individual tools
  - inspect input schema
  - sometimes has output schema

- Chat node will call tools at discretion of LLm
  - Feeds results to LLM to interpret
  - use Agent node to set tool selection
  - Might ignore tools even when prompted to use them
- Structured node will force an LLM to choose a tool
  - Also use Agent node to set selected tools
  - Tool is not called automatically
  - Must pass arguments to Invoke Tools
  - Can manipulate arguments in between
- can also call tools directly via Invoke Tools node
  - provide a JSON object for tool arguments
  - can use Parse JSON or Transform JSON

- We will use an MCP server for rough rate limiting
  - does not account for lag between tool call and next node starting
  - granularity constrained by IPC overhead
  - no way of knowing about retries or connection errors
  - still useful in practice
- from Tools tab click the Import button
  - open `examples/tools/nix/rate-limiter.mcp`
  - Enable and save
- it can take a little time to initialize the first run
- provides tools for each bucket defined in config
- click `limit-openrouter` to examine it
  - there is an input parameter `blocking` that defaults to `true`
    - when true waits until bucket is below limit and returns true
    - when false call returns immediately with false if limit reached
    - if limit not reached, returns true immediately
  - `item` has no functional effect but might be useful for debugging

- To actually use the tool we need 3 things:
  - a tool selection
  - tool arguments
  - a tool invoker
- When manually calling tools the invoker will be an Invoke Tool node
- Tool arguments can be specified on the node itself
- Select Tools will provide the tool selection for all cases

- Back to the iteration example, open the Iterative Subgraph
- Add a Select Tools node and select only `rate-limit/limit-openrouter`
- Add an Invoke Tools node and connect it to the selector
- Since we'll be using the defaults, the arguments field can be blank
- without a direct connection to other nodes this acts as a rate limit on the subgraph
- To have this limit the LLM call, add a Gate node in between the Agent and Structured nodes
- Attach the Invoke Tool output to the `control` pin of the Gate
---

# Tool Use

> [!todo]: demo tool use in chat
