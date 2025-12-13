Class extends _mistral

Class constructor($controller : 4D:C1709.Class)
	
	Super:C1705($controller)
	
Function start($option : Object) : 4D:C1709.SystemWorker
	
	var $command : Text
	$command:=This:C1470.escape(This:C1470.executablePath)
	
	var $arg : Object
	var $valueType : Integer
	var $key : Text
	
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
			"multi_model"; \
			"embedding"].includes($option.command))
			$command+=" "
			$command+=$option.command
			$command+=" "
		End if 
	End if 
	
	//options
	
	Case of 
		: (Value type:C1509($option.model)=Is object:K8:27)\
			 && ((OB Instance of:C1731($option.model; 4D:C1709.File)) || (OB Instance of:C1731($option.model; 4D:C1709.Folder)))\
			 && ($option.model.exists)
			Case of 
				: ($option.command="gguf")
					$command+=" --quantized-model-id "
					$command+=This:C1470.escape($option.model.parent.path)
					$command+=" "
					$command+=" --quantized-filename "
					$command+=This:C1470.escape($option.model.fullName)
					$command+=" "
			End case 
		: (Value type:C1509($option.model)=Is text:K8:3)
			$command+=" -m "
			$command+=This:C1470.escape($option.model)
			$command+=" "
	End case 
	
	For each ($arg; OB Entries:C1720($option))
		Case of 
			: (["model"; "command"].includes($arg.key))
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
				$command+=(" --"+$key+" "+This:C1470.escape(This:C1470.expand($option.model).path))
			Else 
				//
		End case 
	End for each 
	
	//SET TEXT TO PASTEBOARD($command)
	
	return This:C1470.controller.execute($command; $isStream ? $option.model : Null:C1517; $option.data).worker
	