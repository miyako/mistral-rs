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
property URL : Text
property method : Text
property headers : Object
property dataType : Text
property automaticRedirections : Boolean
property file : 4D.File
property options : Object
property _onResponse : 4D.Function
property _fileHandle : 4D.FileHandle
property returnResponseBody : Boolean
property decodeData : Boolean
property range : Object
property bufferSize : Integer
property models : Collection
property event : cs.event.event

Class constructor($port : Integer; $models : Collection; $options : Object; $formula : 4D.Function; $event : cs.event.event)
    
    This.method:="GET"
    This.headers:={Accept: "application/vnd.github+json"}
    This.dataType:="blob"
    This.automaticRedirections:=True
    This.options:=$options#Null ? $options : {}
    This.options.port:=$port
    //This.options.model:=$file
    This.options.models:=$models
    This._onResponse:=$formula
    This.returnResponseBody:=False
    This.decodeData:=False
    This.bufferSize:=10*(1024^2)
    This.event:=$event
    
    This.start()
    
Function _head($model : cs._model)
    
    If ($model.file.parent#Null) && ($model.URL#"")
        $model.file.parent.create()
        This.head($model)
    End if 
    
Function head($model : cs._model)
    
    This.file:=$model.file
    This.URL:=$model.URL
    This.method:="HEAD"
    This.range:={length: 0; start: 0; end: 0}
    //HEAD; async onResponse not supported
    var $request : 4D.HTTPRequest
    $request:=4D.HTTPRequest.new(This.URL; This).wait()
    If ($request.response.status=200)
        This.method:="GET"
        If (Not(This.decodeData))
            This.headers["Accept-Encoding"]:="identity"
        End if 
        If (Value type($request.response.headers["accept-ranges"])=Is text) && \
            ($request.response.headers["accept-ranges"]="bytes")
            This.range.length:=Num($request.response.headers["content-length"])
        End if 
        This._fileHandle:=This.file.open("write")
        If (This.range.length#0)
            var $end; $length : Real
            $end:=This.range.start+(This.bufferSize-1)
            $length:=This.range.length-1
            This.range.end:=$end>=$length ? $length : $end
            This.headers.Range:="bytes="+String(This.range.start)+"-"+String(This.range.end)
        End if 
        4D.HTTPRequest.new(This.URL; This)
    End if 
    
Function start()
    
    var $URLs : Collection
    $URLs:=This.options.models.filter(Formula(Value type($1.value)=Is text))
    
    var $_model : cs._model
    $_model:=This.options.models.query("file.exists == :1"; False).first()
    
    Case of 
        : ($_model#Null)
            
            This._head($_model)
            
        : ($URLs.length#0)
            //hugging face mode
            var $URL : Text
            $URL:=$URLs[0]
            This.options.model:=$URL
            This.file:={name: $URL}
            This.start()
            
        Else 
            
            var $mistral : cs.workers.worker
            $mistral:=cs.workers.worker.new(cs._server)
            $mistral.start(This.options.port; This.options)
            
            If (This.event#Null) && (OB Instance of(This.event; cs.event.event))
                var $model : cs.event.model
                var $_models : Collection
                $_models:=[]
                For each ($_model; This.options.models)
                    $model:=cs.event.model.new($_model.model_id; Not($_model.file.exists))
                    $_models.push($model)
                End for each 
                var $models : cs.event.models
                $models:=cs.event.models.new($_models)
                This.event.onSuccess.call(This; This.options; $models)
            End if 
            
    End case 
    
Function terminate()
    
    var $mistral : cs.workers.worker
    $mistral:=cs.workers.worker.new()
    $mistral.terminate()
    
Function onData($request : 4D.HTTPRequest; $event : Object)
    
    If ($request.dataType="blob") && ($event.data#Null)
        This._fileHandle.writeBlob($event.data)
    End if 
    
    If (This.event#Null) && (OB Instance of(This.event; cs.event.event))
        This.event.onData.call(This; $request; $event)
    End if 
    
Function onResponse($request : 4D.HTTPRequest; $event : Object)
    
    If ($request.dataType="blob") && ($request.response.body#Null)
        This._fileHandle.writeBlob($request.response.body)
    End if 
    
    Case of 
        : (This.range.end=0)  //simple get
            If ($request.response.status=200)
                This._fileHandle:=Null
                If (This.event#Null) && (OB Instance of(This.event; cs.event.event))
                    This.event.onResponse.call(This; $request; $event)
                End if 
                This.start()
            End if 
        Else   //range get
            If ([200; 206].includes($request.response.status))
                This.range.start:=This._fileHandle.getSize()
                If (This.range.start<This.range.length)
                    var $end; $length : Real
                    $end:=This.range.start+(This.bufferSize-1)
                    $length:=This.range.length-1
                    This.range.end:=$end>=$length ? $length : $end
                    This.headers.Range:="bytes="+String(This.range.start)+"-"+String(This.range.end)
                    4D.HTTPRequest.new(This.URL; This)
                Else 
                    This._fileHandle:=Null
                    If (This.event#Null) && (OB Instance of(This.event; cs.event.event))
                        This.event.onResponse.call(This; $request; $event)
                    End if 
                    This.start()
                End if 
            End if 
            
    End case 
    
Function onError($request : 4D.HTTPRequest; $event : Object)
    
    If (Value type(This._onResponse)=Is object) && (OB Instance of(This._onResponse; 4D.Function))
        This._onResponse.call(This; {success: False})
        This._fileHandle:=Null
        This.file.delete()
        This.terminate()
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
