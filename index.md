---
layout: default
---

![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/mistral-rs)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/mistral-rs/total)

# Use mistral.rs from 4D

#### Abstract

[**mistral.rs**](https://github.com/EricLBuehler/mistral.rs) is a multimodal inference engine that supports many LLM models and families, such as Mistral, Llama, Qwen, Gemma, Phi, StarCoder, and more. 

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
You must use a FLUX model in safe tensors format. mistral.rs does not support quantised diffusion models so it needs to load full weights. The preferred model is `black-forest-labs/FLUX.1-schnell` which is `22.15` GiB. If this exceeds physical RAM the system would either crash or swap heavily. 

#### Prerequisites

- An account on Hugging Face
- Agreed to terms of service
- Hugging Face API key with READ access

```
./mistralrs-server --port 8080 --token-source literal:{your_hugging_face_api_key} diffusion -m black-forest-labs/FLUX.1-schnell -a flux
```
