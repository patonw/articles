# Data Extraction

Let's take it a step further and build a workflow that checks whether an article provides evidence to support its claims.

With the Structured node not only can we generate data in a specific format, but we can convert unstructured text into a machine readable format.

## Claim Extraction

- Like before, create a new workflow and swap out the normal Chat for a Structured node
- Create a Parse JSON node for its schema input
- This time we'll use this schema:
  ```json
  {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "title": "ClaimsList",
    "type": "object",
    "properties": {
      "claims": {
        "type": "array",
        "items": {
          "type": "string"
        },
        "minItems": 1,
        "maxItems": 5,
        "description": "A list of claim strings. The list must contain at least one and at most five items."
      }
    },
    "required": [
      "claims"
    ],
    "additionalProperties": false
  }
  ```
- Technically, an array at the top-level would be a valid schema
  - Many models have trouble generating data with that format
  - Easier to wrap the array in an object

- Before we combined instructions with dynamic data into the prompt
- This time, let's use the system message field in the Agent:
  ```text
  Follow these instructions exactly.
  Do not respond directly to the user.
  Do not hallucinate the final answer.

  ## Instructions

  Extract the key factual claims in the user's statement and format them into a list (5 items or fewer).
  Ensure that each claim can stand alone without additional context to make sense of it.
  ```
- The system message is sent once at the beginning of each request
- Theoretically, the LLM should pay more attention to it
- Also avoids sending repeat instructions with every prompt

- With that in place, create add a Plain Text node to hold the article content
- I'm using a Wikipedia article about [apiaries](https://en.wikipedia.org/w/index.php?title=Apiary&action=edit)
- Connect it to the `prompt` input of the Structured node
- It should respond with up to 5 claims

## Claim Checking

- To iterate on each item, we need to unwrap the JSON array
  - Add a Transform JSON node with the filter `.claims`
  - This takes the value of the field named `claims`, which is the array we want
- Before diving into iterative subgraphs, let's sort out the second agent
- Even though our goal is to iterate on each element, it's easier and faster to develop against one item
  - Add another Transform JSON node with the filter `.[1]`
  - This pulls out the second element only

- Add a second Agent node with these instructions:
  ```text
  Follow these instructions exactly.
  Do not respond directly to the user.
  Do not hallucinate the final answer.

  ## Instructions

  Help the user analyze the article in the context file.
  The user is examining individual claims that the article makes.

  Determine whether the context provides supporting evidence for the claim stated by the user.
  List the reference or citation provided by the article.

  DO NOT interpret the article as evidence for a claim made by the user.
  The user is simply examining a claim made by the article.
  ```

- How can we provide the article as context for the LLM? Several ways:
  - Inject it into the system message using templating
  - Provide it as a user message in the conversation
  - Use a Context node
- The last option is easiest, so we'll do that here
- Connect the second agent to the `agent` input
- Connect the Plain Text node with the article to the `context` input

- Optionally, use an unstructured Chat node to do a quick spot check on the Agent
  - Connect the `prompt` input to the isolated claim we unwrapped earlier
- This is just to make sure that the agent sends the context to the LLM

- What we actually want is to generate another structured response with a schema
- Create a new Structured node and connect it to the Context node
- Create a Parse JSON node and connect it to the `schema` input of the Structured node
  ```json
  {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "description": "A factual claim with evidence from citations or references",
    "type": "object",
    "required": [
      "claim",
      "grounding"
    ],
    "properties": {
      "claim": {
        "type": "string",
        "description": "the original claim made by the article"
      },
      "grounding": {
        "enum": [
          "not a claim",
          "unsupported",
          "fully supported"
        ],
        "description": "The level of support for the claim provided by citations and references. If the provided text is actually a definition or something other than a claim, then \"not a claim\""
      },
      "evidence": {
        "type": "array",
        "items": {
          "type": "string"
        },
        "description": "The citations and references that support the claim. Empty if the claim is not supported."
      }
    }
  }
  ```

- Connect the unwrapped claim to the prompt and run
- By changing the claim index we can see how it handles different claims and statements
- Many models will fail to heed the instructions about definitions and include them
- You should see the claims checking agent mark these as "not a claim"

- Now that claims checking Agent works, let's dive into iteration...
