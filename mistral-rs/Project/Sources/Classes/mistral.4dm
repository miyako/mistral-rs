Class constructor($port : Integer; $models : Collection; $options : Object; $event : cs:C1710.event.event)
	
	var $mistral : cs:C1710.workers.worker
	$mistral:=cs:C1710.workers.worker.new(cs:C1710._server)
	
	If (Not:C34($mistral.isRunning($port)))
		
		If ($models=Null:C1517)
			$models:=[]
		End if 
		
		If ($options=Null:C1517)
			$options:={}
		End if 
		
		If ($models.length=0)
			
			var $homeFolder : 4D:C1709.Folder
			$homeFolder:=Folder:C1567(fk home folder:K87:24).folder(".mistral-rs")
			var $model : cs:C1710.mistralModel
			var $file : 4D:C1709.File
			var $URL : Text
			
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
			
			$options.command:="multi-model"
			
		End if 
		
		If ($port=0) || ($port<0) || ($port>65535)
			$port:=8080
		End if 
		
		This:C1470.main($port; $models; $options; $event)
		
	End if 
	
Function onTCP($status : Object; $options : Object)
	
	If ($status.success)
		
		var $className : Text
		$className:=Split string:C1554(Current method name:C684; "."; sk trim spaces:K86:2).first()
		
		CALL WORKER:C1389($className; Formula:C1597(start); $options; Formula:C1597(onModel))
		
	Else 
		
		var $statuses : Text
		$statuses:="TCP port "+String:C10($status.port)+" is aready used by process "+$status.PID.join(",")
		var $error : cs:C1710.event.error
		$error:=cs:C1710.event.error.new(1; $statuses)
		
		If ($options.event#Null:C1517) && (OB Instance of:C1731($options.event; cs:C1710.event.event))
			$options.event.onError.call(This:C1470; $options; $error)
		End if 
		
		This:C1470.terminate()
		
	End if 
	
Function main($port : Integer; $models : Collection; $options : Object; $event : cs:C1710.event.event)
	
	main({port: $port; models: $models; options: $options; event: $event}; This:C1470.onTCP)
	
Function terminate()
	
	var $mistral : cs:C1710.workers.worker
	$mistral:=cs:C1710.workers.worker.new(cs:C1710._server)
	$mistral.terminate()