# Workflow Outputs

Often, the purpose of a workflow is not as a chat agent but as a batch
processor. It might be invoked by another application reading events from a
stream or a pre-commit script of a document repository, for instance. The
invoker would start the workflow with inputs and expect certain outputs. The
chat session is a tangential concern in this situation.

## Creating Outputs

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

## simple-runner

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

## Conclusion

In this article, we've looked at emitting workflow outputs to capture results, independently from the chat history.

To finish our workflow, in the next chapter, we'll add rate limiting to throttle the iteration.
