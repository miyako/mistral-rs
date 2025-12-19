var $mistral : cs:C1710.mistral

If (False:C215)
	$mistral:=cs:C1710.mistral.new()  //default
Else 
	var $homeFolder : 4D:C1709.Folder
	$homeFolder:=Folder:C1567(fk home folder:K87:24).folder(".mistral-rs")
	var $URL : Text
	var $file : 4D:C1709.File
	
	var $port : Integer
	$port:=8084
	
	var $event : cs:C1710.event.event
	$event:=cs:C1710.event.event.new()
/*
Function onError($params : Object; $error : cs.event.error)
Function onSuccess($params : Object; $models : cs.event.models)
Function onData($request : 4D.HTTPRequest; $event : Object)
Function onResponse($request : 4D.HTTPRequest; $event : Object)
Function onTerminate($worker : 4D.SystemWorker; $params : Object)
*/
	
	$event.onError:=Formula:C1597(ALERT:C41($2.message))
	$event.onSuccess:=Formula:C1597(ALERT:C41($2.models.extract("name").join(",")+" loaded!"))
	$event.onData:=Formula:C1597(LOG EVENT:C667(Into 4D debug message:K38:5; "download:"+String:C10((This:C1470.range.end/This:C1470.range.length)*100; "###.00%")))
	$event.onResponse:=Formula:C1597(LOG EVENT:C667(Into 4D debug message:K38:5; "download complete"))
	$event.onTerminate:=Formula:C1597(LOG EVENT:C667(Into 4D debug message:K38:5; (["process"; $1.pid; "terminated!"].join(" "))))
	
	var $models : Collection
	$models:=[]
	
	If (False:C215)  //Hugging Face mode (recommended)
		
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
		
		$URL:="Qwen/Qwen3-Embedding-0.6B-GGUF"
		$file:=Null:C1517
		$model_id:=$URL
		$model:=cs:C1710.mistralModel.new($file; $URL; $model_id; "GGUF"; {\
			dtype: "auto"; arch: "qwen3"; \
			quantized_model_id: $model_id; \
			quantized_filename: "Qwen3-Embedding-0.6B-Q8_0.gguf"; \
			max_batch_size: 2048; \
			max_seq_len: 2048})
		
		$models.push($model)
		
		$mistral:=cs:C1710.mistral.new($port; $models; {command: "multi-model"}; $event)
		
	Else 
		
		//HTTP mode (must be file not folder)
		
		$URL:="https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q5_K_M.gguf"
		$file:=$homeFolder.file("Qwen/Qwen3-1.7B-Q5_K_M.gguf")
		$model_id:="Qwen/Qwen3-1.7B"
		
		$model:=cs:C1710.mistralModel.new($file; $URL; $model_id; "GGUF"; {\
			dtype: "auto"; arch: "qwen3"; \
			quantized_model_id: $model_id; \
			quantized_filename: "Qwen3-1.7B-Q5_K_M.gguf"; \
			max_batch_size: 2048; \
			max_seq_len: 2048})
		
		$models.push($model)
		
		$URL:="https://huggingface.co/Qwen/Qwen3-Embedding-0.6B-GGUF/resolve/main/Qwen3-Embedding-0.6B-Q8_0.gguf"
		$file:=$homeFolder.file("Qwen/Qwen3-Embedding-0.6B-Q8_0.gguf")
		$model_id:="Qwen/Qwen3-Embedding-0.6B"
		
		$model:=cs:C1710.mistralModel.new($file; $URL; $model_id; "GGUF"; {\
			dtype: "auto"; arch: "qwen3"; \
			quantized_model_id: $model_id; \
			quantized_filename: "Qwen3-Embedding-0.6B-Q8_0.gguf"; \
			max_batch_size: 2048; \
			max_seq_len: 2048})
		
		$models.push($model)
		
		$mistral:=cs:C1710.mistral.new($port; $models; {command: "multi-model"}; $event)
		
	End if 
End if 