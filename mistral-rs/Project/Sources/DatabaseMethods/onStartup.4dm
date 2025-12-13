var $mistral : cs:C1710.mistral

If (False:C215)
	$mistral:=cs:C1710.mistral.new()  //default
Else 
	var $modelsFolder : 4D:C1709.Folder
	$modelsFolder:=Folder:C1567(fk home folder:K87:24).folder(".mistral-rs")
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
	
	If (True:C214)
		//custom model download mode
		$URL:="https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q5_K_M.gguf"
		$file:=$modelsFolder.file("Qwen3-1.7B-Q5_K_M.gguf")
		$mistral:=cs:C1710.mistral.new($port; $file; $URL; {command: "gguf"}; $event)
	Else 
		//hugging face mode
		$URL:="EricB/Llama-3.2-11B-Vision-Instruct-UQFF"
		$mistral:=cs:C1710.mistral.new($port; Null:C1517; $URL; {command: "vision-plain"}; $event)
	End if 
End if 