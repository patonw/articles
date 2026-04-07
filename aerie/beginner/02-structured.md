# Structured Generation

In the previous article, we explored generating free-form text in a workflow,
as well as dividing responsibility for different parts of a task among
agents. This time, let's look into generating machine-readable structured data.

> [!tip]
> [Skip to the action](#generating-data) if you're already familiar with structured data and schemas.

## Motivation

Why would we want data to be structured? First, it is easier to filter,
transform and combine documents with automated tools when we know ahead of time
the shape of responses and what properties they can contain.

For instance, if we had to sort and organize thousands of profiles in
unstructured text:

> "John was born twenty five years ago and programs Python"
>
> "Alice is a cryptography expert born in 1998"
>
> etc.

Using traditional text-based tools there are an uncountable number of
permutations, phrasings, exceptions and edge cases to consider. Instead, by
using a language model to transform texts into structured data, we could use
simple operations to fill in missing data and categorize each entry:

```json
[
  {"name": "John", "age": 25, "occupation": "software engineer", "skills": ["python"]},
  {"name": "Alice", "dob": "1998", "occupation": "cryptographer"}
]
```

Second, many external applications and services require structured inputs. If
we can construct structured data, our agents will be able to interact with
these systems, bridging natural language and programmatic logic. In the
parlance of AI agents, these are referred to as "tools" or "functions".

Generative language models are exceptionally good at translating between
unstructured and structured data. Even many small models can extract structured
data from paragraphs reliably. Medium-sized models with long context windows
can often handle larger documents while following specific instructions about
what to find.

## JSON Schema

[JSON](https://en.wikipedia.org/wiki/JSON) (JavaScript Object Notation) is
the de-facto standard for structured data across modern services and applications.
Not only can programs easily parse JSON, but since it is a self-describing format,
even an untrained human user can glean meaning from a JSON document without
needing a deep understanding of its syntax. Most modern LLMs can generate JSON
reliably when creating examples for a user or for invoking remote tools.

To instruct language models on the specific structure desired, we can use [JSON
Schema](https://json-schema.org/overview/what-is-jsonschema).

Schemas themselves are written as JSON documents. They dictate what fields are
required in the target documents, along with type restrictions and more. It
provides a way to describe a JSON document with strict precision, maximum
flexibility or anywhere in between.

> [!tip]
> While you can write schemas from scratch, it may be quicker to either use a
> language model to generate one or specialized a schema editing tool (e.g. [JSONJoy](https://json.ophir.dev)).
> By leveraging LLMs you don't need to know the rules for building schemas [^schema-gen].

[^schema-gen]: You can describe the desired structure, providing examples and
counter-examples, to a language model which will generate a schema. For
instance: "Generate a JSON schema for a user containing a name, login,
department and an optional role."

For this tutorial, however, we'll use one of the canonical examples:
[User Profile](https://json-schema.org/learn/json-schema-examples#user-profile).

## Generating Data

![rename workflow](../assets/2026-02-25_12-23.png)

Start by creating a new workflow from the command palette.

Use the rename button to replace the automatic name.

![schema contents](../assets/2026-02-25_12-34.png)

Remove the Chat node using either the node context menu or Delete key.

Replace it with a *LLM &rsaquo; Structured* node. Conversation history is not
needed this time, but make sure to connect the Agent.

Use a *JSON &rsaquo; Parse JSON* node to provide the schema to the Structured node.
Copy the schema contents from [User Profile](https://json-schema.org/learn/json-schema-examples#user-profile).

This will force the *Structured* node to generate data in the specified format.
If the model fails to produce JSON or does not follow the schema, we can set
the node to retry a number of times.

![generated](../assets/2026-02-25_12-40.png)

Set the prompt describing a user or character and tell the model to follow the schema.

Attach a *Preview* node to the `data` pin of the *Structured* node.

Depending on the model and temperature this may work the first time or it may fail.

You can try switching models or adjusting the temperature or experiment with
the `retry` and `extract` options.

> [!tip]
> The `retry` and `extract` options on the *Structured* node also provide
> mechanisms for coping with different failure modes of weaker models. Often
> when retrying the model will understand its mistake and correct it. Other
> times, the model will get stuck explaining or apologizing while also
> producing correct structured data. For the latter case, the `extract` option
> will attempt to find structured data embedded within the response.
>
> Together, they can prevent most common errors. Sometimes, however, you
> will still want to handle failure recovery within the workflow. Refer to the
> documentation for details.

## Templating

Now that we have a JSON document with a known structure, there are many things
we can do with it. Some examples are request routing, database updates, and
content filtering. However, for this tutorial, we will only use it to generate
unstructured text via a template. At a larger scale, this pattern could also be
used to generate reports from longer documents or collections of items.

> [!note]
> This pattern of generating structured data then formatting it immediately is
> not strictly necessary. LLMs can follow mostly instructions about formatting
> directly, though they often surround replies with unwanted verbiage. However,
> this is just a stand-in for more useful transformations.

![templating](../assets/2026-02-25_13-05.png)

Add a *Value &rsaquo; Template* node to the workflow.

> [!note]
> The *Template* node uses [jinja-like syntax](https://docs.rs/minijinja/latest/minijinja/syntax/index.html) which supports conditionals, filters, iteration and more.

The node takes a template string which may contain variables. On execution, the
node substitutes the variables with concrete values provided by a JSON object
via the `variables` input. Variables can be simple strings, arrays or
dictionaries.

Attach the `variables` input to the `data` output of the *Structured* node and
use this template:

```jinja
## Profile ##

name: {{ username }}
e-mail: {{ email }}
Interests:
  {% for item in interests -%}
    - {{ item }}
  {% endfor %}
```

> [!note]
> If the provided context is not a key-value map (e.g. text value, message, etc.)
> it will be exposed to the template as the variable `value`. This can be handy
> when wrapping a simple value or using a list valued input, without resorting
> to using a [*Transform JSON*](#bonus-transformations) node to wrap the item in a JSON object.

## Conclusion

In addition to generating data directly, we can use the *Structured* node to
extract structured data from existing text as we'll see in upcoming articles.

Beyond simple transformations and templating, we could also use structured data
to control the flow of execution with conditional branching, iteration or
workflow routing which will be covered later.

Before delving into that, however, we will first cover how to work with
external tools to create proper AI agents.

## Bonus: Transformations

As mentioned in the main article, structured data can be merged and transformed
into new structures.

Examples of things you could do include:

- exclude or combine fields
- merge multiple objects
- group elements of a list by field values
- exclude list entries based on value
- remove duplicate entries from a list
- convert a list of entries into a lookup table by name

One popular utility for doing this is the command-line utility
[jq](https://jqlang.org/manual/). The *JSON* sub-menu contains nodes that can
be used together to provide analogous functionality.

For instance, to replicate how *Template* automatically wraps single values,
you can use *JSON &rsaquo; Transform JSON* with a simple filter:
```jq
{ value: . }
```

![transform](../assets/2026-02-25_15-58.png)

You can also combine data from multiple branches of the workflow using
*JSON &rsaquo; Gather JSON*. This node takes multiple inputs and
combines them into a single JSON array. The inputs can be existing JSON values,
texts, numbers or more. By itself, a heterogeneous list of assorted data can be
useful, but confusing to debug. Instead we will transform it into an object
with descriptive keys.

> [!note]
> The *JSON &rsaquo; Transform JSON* node uses an optimized implementation
> called [jaq](https://gedenkt.at/jaq/manual/).

`jq` syntax can be difficult to comprehend at first. Fortunately, many LLMs are
capable of generating filters from a prompt and/or examples.

With the prompt:

> Write a jq filter that takes a list of user entries and creates an object
> keyed by the username field, removing the username field in the process.

Some models might produce this filter:

```jq
reduce .[] as $u ({}; .[$u.username] = $u | del(.username))
```

While others might produce:
```jq
[ .[] 
  | { key: ( .username ), value: ( . | del(.username) ) } 
]  | from_entries
```

Depending on the complexity of the ask, you may need to iterate with the LLM
to fix any problems encountered.
