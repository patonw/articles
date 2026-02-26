# Using Tools

Earlier we introduced how to manage tools and interact with them with a focus
on inspecting and experimenting with them.

This time, we'll integrate a rate limiting tool into a practical workflow.

## Rate limiter

To finish off the claims checker workflow, we'll use a rudimentary rate
limiting tool to throttle calls to the LLM service. This will help you stay
within usage limits dictated by the service and help prevent your account from
getting blocked. This is more likely to be an issue when using iterative
subgraphs, especially with parallelism.

> [!note]
> By packaging a rate limiter in an external tool, it loses sub-second
> granularity and precision. Furthermore, this doesn't account for retries by
> the node.
> 
> Aside from the latency in calling the limiter, there is also a variable gap
> between the limiter and node being limited and the possibility that other
> slow executing nodes are launched in the interim.
>
> Despite those caveats, it's well suited for enforcing limits with per minute granularity.

![import tool](../assets/2026-02-27_15-36.png)

Import the example configuration from
[rate-limter.mcp](https://raw.githubusercontent.com/patonw/refoliate/f772dc2c9bee779ae6c5faca6bac9c658eb5f5e8/aerie/examples/tools/nix/rate-limiter.mcp).

The limits are defined by environment variables with the prefix `BUCKET_`.
`BUCKET_openrouter` is already defined with the free-tier usage limit for the
OpenRouter LLM service. Let's tweak it for demonstrative purposes:

```text
BUCKET_openrouter=1/s,4/15s,20/m
```

![save tool](../assets/2026-02-27_16-35.png)

Be sure to save the configuration before proceeding.

![inspect limiter](../assets/2026-02-28_01-02.png)

Inspect the *rate-limiter &rsaquo; rate-limit* tool. We can see from the input
schema that the only required field is `bucket`:

```json
{
  "name": "rate-limit",
  "description": "Wait until a permit for `bucket` is available",
  "inputSchema": {
    "additionalProperties": false,
    "properties": {
      "bucket": {
        "description": "Name of a bucket defined in server configuration",
        "type": "string"
      },
      "blocking": {
        "default": true,
        "description": "Wait until permits available before returning",
        "type": "boolean"
      },
      "item": {
        "default": "",
        "description": "Name of the item to store in the bucket",
        "type": "string"
      }
    },
    "required": [
      "bucket"
    ],
    "type": "object"
  },
  "outputSchema": {
    "properties": {
      "result": {
        "type": "boolean"
      }
    },
    "required": [
      "result"
    ],
    "type": "object",
    "x-fastmcp-wrap-result": true
  }
}
```

To actually use the tool we'll need three things:
  - tool selection
  - tool arguments
  - tool invoker

> [!note]
> Normally, the arguments would come from an LLM or result from transforming data.
> For trivial cases like this, we can write them directly into the Invoke Tool node.

![select tools](../assets/2026-02-28_01-10.png)

Let's create the necessary nodes in the top-level workflow, then move them into
the subgraph later. Add *Tools &rsaquo; Select Tools* and *Tools &rsaquo;
Invoke Tool*. Connect their `tools` pins. Check `rate-limit` to enable the
limiter tool.

Since only one tool is selected, the Invoke Tool does not need a tool name. Set
it if you like or leave it blank. However, as we saw from inspecting the tool
schema, a bucket name is required. Specify that by setting the arguments field:

```json
{
  "bucket": "openrouter"
}
```

> [!tip]
> You may have noticed the `limit-<bucket>` tools. These are bucket specific
> and don't have any required arguments. You can call them without any
> arguments. This will not be the case with the majority of tools, though.

![limit reruns](../assets/2026-02-27_16-44.png)

Select the Invoke Tool node and re-run it five times. The first four should
finish within a second. The fifth run can take up to 11 seconds, according to
the demo rates we set above.

![limit subgraph](../assets/2026-02-28_01-19.png)

Cut and paste the tools nodes into the subgraph. As is, this will act as a
coarse limit on subgraph iterations. For per-minute granularity, this is good
enough. To get finer control over the LLM call, though, we'll need a way to
interrupt the workflow before it calls the LLM.

![gate](../assets/2026-02-28_01-21.png)

Add a *Control &rsaquo; Gate* node and connect its `control` pin to the Invoke Tool node.
Rewire the Context and Structured nodes to route the agent through Gate.

> [!note]
> The Gate node simply withholds a data value until the control wire is ready.

> [!tip]
> It's possible for slow nodes to run between the time the limiter returns and
> the LLM is called. This would weaken the precision of the rate and could
> cause requests to fail. To delay running the limiter until all dependencies
> of the LLM finish, use *Control &rsaquo; Demote*.

## Wrapping Up

Now that we've handled the critical steps of the workflow, there are just a few
things remaining to complete the workflow.

![chat summary](../assets/2026-03-02_11-24.png)

First, let's summarize the results using a Chat node. We can provide the
instructions in the agent's system message:

> Summarize the results provided by the user.
>
> Start off by concluding whether or not the claims are supported or not, as a whole.

Sending the conversation history to the Finish node makes iteration results and
summary available in the Chat tab. The prior steps are discarded. There are
various nodes for manipulating the conversation that allow this history to be
preserved, but we'll skip them for now, in the interest of time.

> [!tip]
> This Chat node should have it's own rate-limit invocation, for correctness.

Finally, replace the static Text node by wiring the input pin of the Start node
to both subgraphs.

## Bonus: Workflow Outputs

Often, the purpose of a workflow is not as a chat agent but as a batch
processor. It might be invoked by another application reading events from a
stream or a pre-commit script of a document repository, for instance. The
invoker would start the workflow with inputs and expect certain outputs. The
chat session is a tangential concern in this situation.

Adding Output nodes to the top-level workflow produces named outputs. Depending
on how the workflow is launched, they can be emitted either to the console or
as individual files.

In the claims checking example a user might want to see all claims with
evidence and a list of only the unsupported ones.

![claims out](../assets/2026-03-02_11-55.png)

Capturing all processed claims is simply a matter of connecting an Output node
directly to the subgraph.

![output tab](../assets/2026-03-02_11-59.png)

When running from the UI, you can inspect or save the workflows outputs from
the Output tab.

> [!important]
> The UI does not save outputs automatically. Outputs not manually saved will
> be discarded when the application exits.

![unsupported filter](../assets/2026-03-02_12-01.png)

To extract only the unsupported claims, we need to transform with a small filter:

```jq
[.[] | select(.grounding == "unsupported")]
```

### simple-runner

The simple-runner utility can run a workflow non-interactively from the console.

From a source build you can use `cargo run --bin simple-runner` or
`aerie-runner` from an installation.

```bash
cargo run --release --bin simple-runner -- \
  -w ~/.local/share/aerie/workflows/ \
  -t ~/.local/share/aerie/tools/ \
  -m openrouter/openrouter/free \
  -I ~/tmp/article.txt \
  claim-jumper
```

It will run for a while without any indication of progress and eventually
produce something resembling:

```json
{
  "claims.json": [
    {
      "evidence": [],
      "claim": "An apiary is a location where beehives of honey bees are kept.",
      "grounding": "not a claim"
    },
    {
      "evidence": [
        "https://www.merriam-webster.com/dictionary/apiary"
      ],
      "claim": "The word \\\"apiary\\\" was first used in 1654.",
      "grounding": "fully supported"
    },
    {
      "claim": "In the Northern Hemisphere, east- and south-facing sites with full morning sun are preferred for apiaries.",
      "grounding": "unsupported",
      "evidence": []
    },
    {
      "grounding": "fully supported",
      "claim": "In the United States, the most lucrative regions for honey production are Florida, Texas, California, and the Upper Midwest.",
      "evidence": [
        "http://www.beeculture.com/u-s-honey-industry-report-2016/"
      ]
    },
    {
      "claim": "Internationally, the largest honey-producing exporters are China, Germany, and Mexico.",
      "grounding": "fully supported",
      "evidence": [
        "https://worldtradedaily.com/2012/07/28/honey-world-production-top-exporters-top-importers-and-untied-states-imports-by-country/"
      ]
    }
  ],
  "unsupported.json": [
    {
      "claim": "In the Northern Hemisphere, east- and south-facing sites with full morning sun are preferred for apiaries.",
      "grounding": "unsupported",
      "evidence": []
    }
  ]
}
```

[^mcp-lists]: Some MCP server directories:
  https://github.com/modelcontextprotocol/servers
  https://mcpservers.com/
  https://mcpindex.net/en
  https://mcpserverdirectory.org/

