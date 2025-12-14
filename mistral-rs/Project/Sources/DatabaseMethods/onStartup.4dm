var $mistral : cs:C1710.mistral

If (False:C215)
	$mistral:=cs:C1710.mistral.new()  //default
Else 
	var $homeFolder : 4D:C1709.Folder
	$homeFolder:=Folder:C1567(fk home folder:K87:24).folder(".mistral-rs")
	var $URL : Text
	var $file : 4D:C1709.File
	
	var $port : Integer
	$port:=8080
	
	var $event : cs:C1710.mistralEvent
	$event:=cs:C1710.mistralEvent.new()
/*
Function onError($params : Object; $error : cs._error)
Function onSuccess($params : Object)
*/
	$event.onError:=Formula:C1597(ALERT:C41($2.message))
	$event.onSuccess:=Formula:C1597(ALERT:C41($1.models.extract("model_id").join(",")+" loaded!"))
	
	var $models : Collection
	$models:=[]
	
	Case of 
		: (True:C214)  //2 models, hugging face
			
			$URL:="EricB/Llama-3.2-11B-Vision-Instruct-UQFF"
			$file:=Null:C1517
			$model_id:=$URL
			$model:=cs:C1710.mistralModel.new($file; $URL; $model_id; "VisionPlain"; {\
				dtype: "auto"; \
				max_num_images: 4; \
				max_image_length: 1024; \
				max_batch_size: 2048; \
				max_seq_len: 2048})
			$models.push($model)
			
			//https://ericlbuehler.github.io/mistral.rs/mistralrs/enum.ModelSelected.html
			
/*		
nomic: ERROR
Unknown GGUF architecture `nomic-bert`
			
EmbeddingGemma: ERROR
Unsupported Hugging Face Transformers -CausalLM model class `Gemma3TextModel`
			
MiniLM
Unsupported Hugging Face Transformers -CausalLM model class `BertModel`
*/
			
/*
arch:
one of 
`mistral`, 
`gemma`, 
`mixtral`, 
`llama`, 
`phi2`, 
`phi3`, 
`qwen2`, 
`gemma2`, 
`starcoder2`, 
`phi3.5moe`, 
`deepseekv2`, 
`deepseekv3`, 
`qwen3`, 
`glm4`, 
`qwen3moe`, 
`smollm3`, 
`granitemoehybrid`
https://ericlbuehler.github.io/mistral.rs/mistralrs/enum.NormalLoaderType.html
*/
			
			Case of 
				: (False:C215)
					$URL:="microsoft/Phi-3-mini-4k-instruct"
					$file:=Null:C1517
					$model_id:=$URL
					$model:=cs:C1710.mistralModel.new($file; $URL; $model_id; "Plain"; {\
						dtype: "auto"; arch: "phi3"})
				: (True:C214)
					$URL:="Qwen/Qwen3-Embedding-0.6B-GGUF"
					$file:=Null:C1517
					$model_id:=$URL
					$model:=cs:C1710.mistralModel.new($file; $URL; $model_id; "GGUF"; {\
						dtype: "auto"; arch: "qwen3"; \
						quantized_model_id: $model_id; \
						quantized_filename: "Qwen3-Embedding-0.6B-Q8_0.gguf"; \
						max_batch_size: 2048; \
						max_seq_len: 2048})
			End case 
			
			$models.push($model)
			
			$mistral:=cs:C1710.mistral.new($port; $models; {command: "multi-model"}; $event)
			
		: (False:C215)  //1 model, hugging face
			
			$URL:="EricB/Llama-3.2-11B-Vision-Instruct-UQFF"
			$file:=Null:C1517
			$model_id:=$URL
			$model:=cs:C1710.mistralModel.new($file; $URL; $model_id)
			$models.push($model)
			
			$mistral:=cs:C1710.mistral.new($port; $models; {command: "vision-plain"}; $event)
			
		: (False:C215)  //1 model, custom URL
			
			//custom model download mode
			$URL:="https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q5_K_M.gguf"
			$file:=$homeFolder.file("Qwen/Qwen3-1.7B-Q5_K_M.gguf")
			$model_id:="Qwen/Qwen3-7B"
			
			$model:=cs:C1710.mistralModel.new($file; $URL; $model_id)
			$models.push($model)
			
			$mistral:=cs:C1710.mistral.new($port; $models; {command: "gguf"}; $event)
			
		Else 
			//
	End case 
End if 