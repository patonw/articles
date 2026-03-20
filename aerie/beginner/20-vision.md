# Visual Language Workflows

Visual language models accept a mix of text and image inputs to generate text
or call tools. They can be used for visual question answering, flexible
captioning or extracting structured data from images.

In a workflow, you can successively refine results based on one or more
reference images or iterate over extracted elements. Beyond transcribing text
from images, structured extraction can also be used for things like scene
composition, content moderation or sentiment analysis.

Use cases:
- Content moderation
- Pre-labelling training data
- Question answering
- Data entry

## Image Chat

You can supply images to workflows from the Chat tab.
Images are bundled with the prompt text to form the input message.
Loading images from local disk or remote URLs is supported.

Let's find an interesting stock image [^stock] and copy the link.

[^stock]: [picsum](https://picsum.photos/images) is a handy service for stock
    placeholder images

![add link](../assets/2026-03-24_12-38.png)

Click the Add Image Link button on the Chat tab and paste the link into the dialog.

![image added](../assets/2026-03-24_12-43.png)

The image(s) will appear in a small thumbnail gallery. Hover for a preview or
click on one to remove it.

![empty workflow](../assets/2026-03-24_12-40.png)

Change the Workflow to none (blank) and submit.

![image chat](../assets/2026-03-24_12-45.png)

As with the prompt, launching a workflow from the Chat window will clear input images.

## Image Workflows

![image input](../assets/2026-03-24_17-12.png)

Inside a workflow, the `input` pin of the *Start* node combines the text prompt
and images into a single message value.

![image workflow](../assets/2026-03-24_14-19.png)

You can also attach images to text using the *History &rsaquo; Create Message*
node. The `images` input accepts a text or list value of URLs to load. These
can be remote HTTP assets or data URLs.

> [!note]
> Local files also work but not recommended since they will not be bundled with
> your workflow on export.

The *Chat* and *Structured* nodes accept prompts with images. Images are also
supported in conversation histories.

> [!note]
> Large images are downscaled automatically. Vision models typically support a
> native resolution of under 500 pixels. Furthermore, many provider APIs
> have a limit on request size of megabytes.

## Visual Extraction

As a final task, let's use structured generation and iteration to identify
manufactured items in an image and write a slogan for each.

We'll use a *Structured* node with a schema to format the data into a list that
we can iterate over.

![extraction](../assets/2026-03-24_15-44.png)

Replace *Chat* node with *Structured*.

Create a *Parse JSON* node with this schema:
```json
{
  "type": "object",
  "properties": {
    "entities": {
      "type": "array",
      "description": "A list of manufactured entities",
      "maxItems": 3,
      "items": {
        "type": "string"
      }
    }
  },
  "required": [
    "entities"
  ]
}
```

Connect it to the `schema` pin of *Structured* node.

Change the prompt to: 
```text
List up to 3 of the most prominent man-made objects in the image.
If there are none, return an empty list.
Ignore high-tech electronics and items in the background or periphery.
```

![slogan chat](../assets/2026-03-24_15-49.png)

Add *Transform JSON* with the filter `.entities[0]` and connect it to the
`data` pin of *Structured*.

Add *Value &rsaquo; Template* with the body:
```jinja
Write a catchy advertising slogan for *{{ value }}* as it appears in the image.
Take into account the context of the image.
```

Add new *Agent* and *Chat* nodes, ensuring that the conversation pin is
connected to the previous *Structured* node. Experiment with different
temperatures.

> [!note]
> Notice that we're not injecting the image into the second prompt. Because
> it's already part of the conversation, we can refer to the existing instance,
> as long as the conversation is passed between nodes.

![slogan subgraph](../assets/2026-03-24_15-54.png)

Once you're satisfied with the results, let's move it into an *Iterative Subgraph*.

![subgraph connected](../assets/2026-03-24_16-00.png)

Modify the existing *Transform JSON* to return all entities as a list using the
filter: `.entities`. Because subgraphs are strict about their inputs, you'll
need to use *Unwrap JSON* to extract a text list first.

## Conclusion

This demonstrates a fairly simple creative workflow using visual language
models. Some models may be suitable for business oriented applications,
extracting items from receipts for instance. While specialized captioning, text
recognition, etc models might provide better accuracy and performance, the
flexibility and power of visual language models makes them good as a first
resort.
