Class extends _mistral

Class constructor($controller : 4D:C1709.Class)
	
	Super:C1705($controller)
	
Function start($option : Object) : 4D:C1709.SystemWorker
	
	var $command : Text
	$command:=This:C1470.escape(This:C1470.executablePath)
	
	var $arg : Object
	var $valueType : Integer
	var $key : Text
	
	$config_json:={}
	
	var $models : Collection
	$models:=[]
	If ($option.models#Null:C1517)
		var $model : cs:C1710.mistralModel
		$i:=1
		For each ($model; $option.models)
			
			$entry:="model_"+String:C10($i)
			$i+=1
			$item:={}
			$content:={}
			
			If ($model.model="")
				$model.model:="Plain"
			End if 
			
			For each ($arg; OB Entries:C1720($model.options))
				$valueType:=Value type:C1509($arg.value)
				$key:=$arg.key
				Case of 
					: ($valueType=Is real:K8:4)
						$content[$key]:=$arg.value
					: ($valueType=Is text:K8:3)
						$content[$key]:=$arg.value
					: ($valueType=Is boolean:K8:9)
						$content[$key]:=$arg.value
					: ($valueType=Is object:K8:27) && ((OB Instance of:C1731($arg.value; 4D:C1709.File)) || (OB Instance of:C1731($arg.value; 4D:C1709.Folder)))
						$content[$key]:=This:C1470.expand($arg.value).path
					Else 
						//
				End case 
			End for each 
			
			$content.model_id:=$model.model_id
			
			$item[$model.model]:=$content
			
			If ($model.jinja_explicit#Null:C1517) && (OB Instance of:C1731($model.jinja_explicit; 4D:C1709.File)) && ($model.jinja_explicit.exists)
				$item.jinja_explicit:=This:C1470.expand($model.jinja_explicit).path
			End if 
			If ($model.chat_template#"")
				$item.chat_template:=$model.chat_template
			End if 
			If ($model.num_device_layers#0)
				$item.num_device_layers:=$model.num_device_layers
			End if 
			If ($model.in_situ_quant#"")
				$item.in_situ_quant:=$model.in_situ_quant
			End if 
			$config_json[$entry]:=$item
		End for each 
	End if 
	
	For each ($arg; OB Entries:C1720($option))
		Case of 
			: (["interactive-mode"; "help"].includes($arg.key))
				continue
		End case 
		Case of 
			: (["port"; \
				"mcp-config"; "mcp-port"; \
				"enable-thinking"; \
				"search-embedding-model"; "enable-search"; \
				"cpu"; "paged-attn"; \
				"no-paged-attn"; "pa-blk-size"; \
				"pa-cache-type"; "pa-ctxt-len"; \
				"pa-gpu-mem-usage"; "pa-gpu-mem"; "isq"; \
				"serve-ip"; "seed"; "log"; "max-seqs"; \
				"no-kv-cache"; "chat-template"; \
				"jinja-explicit"; "token-source"; \
				"num-device-layers"; "prefix-cache-n"].includes($arg.key))
				$valueType:=Value type:C1509($arg.value)
				$key:=Replace string:C233($arg.key; "_"; "-"; *)
				OB REMOVE:C1226($option; $arg.key)
				Case of 
					: ($valueType=Is real:K8:4)
						$command+=(" --"+$key+" "+String:C10($arg.value)+" ")
					: ($valueType=Is text:K8:3)
						$command+=(" --"+$key+" "+This:C1470.escape($arg.value)+" ")
					: ($valueType=Is boolean:K8:9) && ($arg.value)
						$command+=(" --"+$key+" ")
					: ($valueType=Is object:K8:27) && ((OB Instance of:C1731($arg.value; 4D:C1709.File)) || (OB Instance of:C1731($arg.value; 4D:C1709.Folder)))
						$command+=(" --"+$key+" "+This:C1470.escape(This:C1470.expand($option.model).path))
					Else 
						//
				End case 
		End case 
	End for each 
	
	//commands
	
	If (Value type:C1509($option.command)=Is text:K8:3)
		If ([\
			"toml"; \
			"run"; \
			"plain"; \
			"x-lora"; \
			"lora"; \
			"gguf"; \
			"x-lora-gguf"; \
			"lora-gguf"; \
			"ggml"; \
			"x-lora-ggml"; \
			"lora-ggml"; \
			"vision-plain"; \
			"diffusion"; \
			"speech"; \
			"multi-model"; \
			"embedding"].includes($option.command))
			$command+=" "
			$command+=$option.command
			$command+=" "
			
			If ($option.command="multi-model")
				
/*
 --config config.json --default-model-id meta-llama/Llama-3.2-3B-Instruct
*/
				
				var $homeFolder : 4D:C1709.Folder
				$homeFolder:=Folder:C1567(fk home folder:K87:24).folder(".mistral-rs")
				$homeFolder.create()
				
				var $configFile : 4D:C1709.File
				$configFile:=$homeFolder.file("config.json")
				$configFile.setText(JSON Stringify:C1217($config_json; *))
				
				$command+=" --config "
				$command+=This:C1470.escape($configFile.path)
				$command+=" "
				
			End if 
		End if 
	End if 
	
	//options
	
	If ($option.command#"multi-model")
		$model:=$option.models.first()
		If ($model#Null:C1517)
			Case of 
				: (Value type:C1509($model.file)=Is object:K8:27)\
					 && ((OB Instance of:C1731($model.file; 4D:C1709.File)) || (OB Instance of:C1731($model.file; 4D:C1709.Folder)))\
					 && ($model.file.exists)
					Case of 
						: ($option.command="gguf")
							$command+=" --quantized-model-id "
							$command+=This:C1470.escape($model.file.parent.path)
							$command+=" "
							$command+=" --quantized-filename "
							$command+=This:C1470.escape($model.file.fullName)
							$command+=" "
					End case 
				Else 
					$command+=" -m "
					$command+=This:C1470.escape($model.model_id)
					$command+=" "
			End case 
		Else 
			return 
		End if 
	End if 
	
	For each ($arg; OB Entries:C1720($option))
		Case of 
			: (["models"; "command"].includes($arg.key))
				continue
		End case 
		$valueType:=Value type:C1509($arg.value)
		$key:=Replace string:C233($arg.key; "_"; "-"; *)
		Case of 
			: ($valueType=Is real:K8:4)
				$command+=(" --"+$key+" "+String:C10($arg.value)+" ")
			: ($valueType=Is text:K8:3)
				$command+=(" --"+$key+" "+This:C1470.escape($arg.value)+" ")
			: ($valueType=Is boolean:K8:9) && ($arg.value)
				$command+=(" --"+$key+" ")
			: ($valueType=Is object:K8:27) && ((OB Instance of:C1731($arg.value; 4D:C1709.File)) || (OB Instance of:C1731($arg.value; 4D:C1709.Folder)))
				$command+=(" --"+$key+" "+This:C1470.escape(This:C1470.expand($arg.value).path))
			Else 
				//
		End case 
	End for each 
	
	//SET TEXT TO PASTEBOARD($command)
	
	return This:C1470.controller.execute($command; $isStream ? $option.model : Null:C1517; $option.data).worker
	