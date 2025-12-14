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
	$event.onSuccess:=Formula:C1597(ALERT:C41(This:C1470.file.name+" loaded!"))
	
	var $models : Collection
	$models:=[]
	
	Case of 
		: (False:C215)  //2 models, gguf [ERROR]
			
			//custom model download mode
			$URL:="https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q5_K_M.gguf"
			$file:=$homeFolder.file("Qwen/Qwen3-1.7B-Q5_K_M.gguf")
			$model_id:="Qwen/Qwen3-7B"
			
			$model:=cs:C1710.mistralModel.new($file; $URL; $model_id)
			$models.push($model)
			
			$URL:="https://huggingface.co/nomic-ai/nomic-embed-text-v1-GGUF/resolve/main/nomic-embed-text-v1.f16.gguf"
			$file:=$homeFolder.file("nomic/nomic-embed-text-v1.f16.gguf")
			$model_id:="nomic/nomic-embed-text-v1"
			
			$model:=cs:C1710.mistralModel.new($file; $URL; $model_id)
			$models.push($model)
			
			$mistral:=cs:C1710.mistral.new($port; $models; {command: "multi-model"}; $event)
			
		: (True:C214)  //2 models, hugging face
			
			$URL:="EricB/Llama-3.2-11B-Vision-Instruct-UQFF"
			$file:=Null:C1517
			$model_id:=$URL
			$model:=cs:C1710.mistralModel.new($file; $URL; $model_id; Null:C1517; ""; 0; "4")
			$models.push($model)
			
			$URL:="Qwen/Qwen3-4B"
			$file:=Null:C1517
			$model_id:=$URL
			$model:=cs:C1710.mistralModel.new($file; $URL; $model_id; Null:C1517; ""; 0; "4")
			$models.push($model)
			
			$mistral:=cs:C1710.mistral.new($port; $models; {command: "multi-model"}; $event)
			
		: (False:C215)  //1 model, hugging face
			
			$URL:="EricB/Llama-3.2-11B-Vision-Instruct-UQFF"
			$file:=Null:C1517
			$model_id:=$URL
			$model:=cs:C1710.mistralModel.new($file; $URL; $model_id)
			$models.push($model)
			
			$mistral:=cs:C1710.mistral.new($port; $models; {command: "vision-plain"}; $event)
			
		: (False:C215)  //1 model, gguf
			
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