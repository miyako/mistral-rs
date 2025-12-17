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

mistral․rs is designed to **work directly with native Hugging Face models** while reducing memory consumption by quantising  at runtime ([ISQ](https://github.com/EricLBuehler/mistral.rs/blob/master/docs/ISQ.md)). There is also a [tool](https://github.com/EricLBuehler/uqff_maker) to save the model in [quantised format ](https://github.com/EricLBuehler/mistral.rs/blob/master/docs/UQFF.md). Some models can be loaded from .gguf files.

mistral․rs has a build in HTTP server with Open AI compatible endpoints. The server can automatically [**connect to external MCP servers**](https://github.com/EricLBuehler/mistral.rs/blob/master/examples/MCP_QUICK_START.md).

#### Usage

Instantiate `cs.mistral.mistral` in your *On Startup* database method:

```4d
var $mistral : cs.mistral.mistral

If (False)
    $mistral:=cs.mistral.mistral.new()  //default
Else 
    var $homeFolder : 4D.Folder
    $homeFolder:=Folder(fk home folder).folder(".mistral-rs")
    var $URL : Text
    var $file : 4D.File
    
    var $port : Integer
    $port:=8080
    
    var $event : cs.event.event
    $event:=cs.event.event.new()
    /*
        Function onError($params : Object; $error : cs.event.error)
        Function onSuccess($params : Object; $models : cs.event.models)
    */
    $event.onError:=Formula(ALERT($2.message))
    $event.onSuccess:=Formula(ALERT($2.models.extract("name").join(",")+" loaded!"))
    $event.onData:=Formula(MESSAGE(String((This.range.end/This.range.length)*100; "###.00%")))  //onData@4D.HTTPRequest
    $event.onResponse:=Formula(ERASE WINDOW)  //onResponse@4D.HTTPRequest
    
    var $models : Collection
    $models:=[]
    
    If (False)  //Hugging Face mode (recommended)
        
        $URL:="EricB/Llama-3.2-11B-Vision-Instruct-UQFF"
        $file:=Null
        $model_id:=$URL
        $model:=cs.mistralModel.new($file; $URL; $model_id; "VisionPlain"; {\
        dtype: "auto"; \
        max_num_images: 4; \
        max_image_length: 1024; \
        max_batch_size: 2048; \
        max_seq_len: 2048})
        $models.push($model)
        
        $URL:="Qwen/Qwen3-Embedding-0.6B-GGUF"
        $file:=Null
        $model_id:=$URL
        $model:=cs.mistralModel.new($file; $URL; $model_id; "GGUF"; {\
        dtype: "auto"; arch: "qwen3"; \
        quantized_model_id: $model_id; \
        quantized_filename: "Qwen3-Embedding-0.6B-Q8_0.gguf"; \
        max_batch_size: 2048; \
        max_seq_len: 2048})
        
        $models.push($model)
        
        $mistral:=cs.mistral.mistral.new($port; $models; {command: "multi-model"}; $event)
        
    Else 
        
        //HTTP mode (must be file not folder)
        
        $URL:="https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q5_K_M.gguf"
        $file:=$homeFolder.file("Qwen/Qwen3-1.7B-Q5_K_M.gguf")
        $model_id:="Qwen/Qwen3-1.7B"
        
        $model:=cs.mistralModel.new($file; $URL; $model_id; "GGUF"; {\
        dtype: "auto"; arch: "qwen3"; \
        quantized_model_id: $model_id; \
        quantized_filename: "Qwen3-1.7B-Q5_K_M.gguf"; \
        max_batch_size: 2048; \
        max_seq_len: 2048})
        
        $models.push($model)
        
        $URL:="https://huggingface.co/Qwen/Qwen3-Embedding-0.6B-GGUF/resolve/main/Qwen3-Embedding-0.6B-Q8_0.gguf"
        $file:=$homeFolder.file("Qwen/Qwen3-Embedding-0.6B-Q8_0.gguf")
        $model_id:="Qwen/Qwen3-Embedding-0.6B"
        
        $model:=cs.mistralModel.new($file; $URL; $model_id; "GGUF"; {\
        dtype: "auto"; arch: "qwen3"; \
        quantized_model_id: $model_id; \
        quantized_filename: "Qwen3-Embedding-0.6B-Q8_0.gguf"; \
        max_batch_size: 2048; \
        max_seq_len: 2048})
        
        $models.push($model)
        
        $mistral:=cs.mistral.mistral.new($port; $models; {command: "multi-model"}; $event)
        
    End if 
End if 
```

Unless the server is already running (in which case the costructor does nothing), the following procedure runs in the background:

1. The specified model is downloaded via HTTP
2. The `mistralrs-server` program is started

Now you can test the server:

```
curl -X POST http://127.0.0.1:8080/v1/embeddings \
     -H "Content-Type: application/json" \
     -d '{"input":"The quick brown fox jumps over the lazy dog."}'
```

Or, use AI Kit:

```4d
var $AIClient : cs.AIKit.OpenAI
$AIClient:=cs.AIKit.OpenAI.new()
$AIClient.baseURL:="http://127.0.0.1:8080/v1"

var $text : Text
$text:="The quick brown fox jumps over the lazy dog."

var $responseEmbeddings : cs.AIKit.OpenAIEmbeddingsResult
$responseEmbeddings:=$AIClient.embeddings.create($text)
```

Finally to terminate the server:

```4d
var $mistral : cs.mistral.mistral
$mistral:=cs.mistral.mistral.new()
$mistral.terminate()
```

#### Models

You can find popular quantised UQFF models on [Hugging Face](https://huggingface.co/collections/EricB/uqff), except for image generation.

Here are a few models smaller than a gigabyte:

|Model|Parameters|Quantisation|Size|
|-|-:|-:|-:|
|[Qwen3](https://huggingface.co/EricB/Qwen3-1.7B-UQFF/resolve/main/qwen31.7b-q4k-0.uqff)|`1.7B`|`Q4K_0`|`968 MB`|
|[Llama 3.2](https://huggingface.co/EricB/Llama-3.2-1B-Instruct-UQFF/resolve/main/llama3.2-1b-instruct-q5k.uqff)|`1B`|`Q5_K`|`850 MB`|

Vision models tend to exceed `4` gigabytes:

|Model|Parameters|Quantisation|Size|
|-|-:|-:|-:|
|[Phi-3.5](https://huggingface.co/EricB/Phi-3.5-vision-instruct-UQFF/resolve/main/phi3.5-vision-instruct-q4k.uqff)|`4.2B`|`Q4`|`2.09 GB`|
|[Llama 3.2](https://huggingface.co/EricB/Llama-3.2-11B-Vision-Instruct-UQFF/resolve/main/llama3.2-vision-instruct-q4k.uqff)|`11B`|`Q4K`|`4.37 GB`|

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

But realistically, the server will crash unless it has GPU and `32 GB` or more VRAM.

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
