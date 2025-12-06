---
layout: default
---

![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/mistral-rs)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/mistral-rs/total)

# Use mistral.rs from 4D

#### Abstract

[**mistral.rs**](https://github.com/EricLBuehler/mistral.rs) is a multimodal local inference engine with a [Candle](https://github.com/huggingface/candle) backend that supports many LLM models and families, such as Mistral, Llama, Qwen, Gemma, Phi, StarCoder, and more. 

mistral․rs is designed to work primarily with native Hugging Face models but reduce memory consumption and increase inference speed by quantising  at runtime ([ISQ](https://github.com/EricLBuehler/mistral.rs/blob/master/docs/ISQ.md)). There is a [tool](https://github.com/EricLBuehler/uqff_maker) to save the model in [quantised format ](https://github.com/EricLBuehler/mistral.rs/blob/master/docs/UQFF.md). 

mistral․rs has a build in HTTP server with Open AI compatible endpoints. The server can automatically [**connect to external MCP servers**](https://github.com/EricLBuehler/mistral.rs/blob/master/examples/MCP_QUICK_START.md).

#### Models

You can find popular quantised UQFF models on [Hugging Face](https://huggingface.co/collections/EricB/uqff), except for image generation.

Here are a few models smaller than a gigabyte:

|Model|Parameters|Quantisation|Size|
|-|-:|-|
|[Qwen3](https://huggingface.co/EricB/Qwen3-1.7B-UQFF/resolve/main/qwen31.7b-q4k-0.uqff)|`1.7B`|`Q4K_0`|`968 MB`|
|[Llama-3.2-Instruct](https://huggingface.co/EricB/Llama-3.2-1B-Instruct-UQFF/resolve/main/llama3.2-1b-instruct-q5k.uqff)|`1B`|`Q5_K`|`850 MB`|

#### AI Kit compatibility

The API is compatibile with [Open AI](https://platform.openai.com/docs/api-reference/embeddings). 

|Class|API|Availability|
|-|-|:-:|
|Models|`/v1/models`|✅|
|Chat|`/v1/chat/completions`|✅|
|Images|`/v1/images/generations`|✅|
|Moderations|`/v1/moderations`||
|Embeddings|`/v1/embeddings`|✅|
|Files|`/v1/files`||

#### Image Generation

mistral.rs supports image generation. 
You must use a FLUX model in native Hugging Face model format because quantisation is not supported for `diffusion`. The standard `black-forest-labs/FLUX.1-schnell` model is `24 GiB` in size, which is too large for a miid-range laptop PC. 

To use a FLUX model from Hugging Face you need to satisfy the following prerequisites:

1. Created an account on Hugging Face
2. Agreed to their terms of service
3. Generated a Hugging Face API key with READ access

Now you can test the server:

```
./mistralrs-server --port 8080 --token-source literal:{your_hugging_face_api_key} diffusion -m black-forest-labs/FLUX.1-schnell -a flux
```

Or, use AI Kit:

```4d
var $AIClient : cs.AIKit.OpenAI
$AIClient:=cs.AIKit.OpenAI.new()
$AIClient.baseURL:="http://127.0.0.1:8080/v1"

var $text : Text
$text:="A futuristic city skyline at sunset"

var $parameters : cs.AIKit.OpenAIImageParameters
$parameters:=cs.AIKit.OpenAIImageParameters.new()
$parameters.size:="1024x1024"


var $result : cs.AIKit.OpenAIImagesResult
$result:=$AIClient.images.generate($text; $parameters)

If ($result.image#Null)
    $result.image.saveToDisk(Folder(fk desktop folder).file("skylinecity.png"))
End if 
```

