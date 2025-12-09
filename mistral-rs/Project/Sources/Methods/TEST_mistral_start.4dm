//%attributes = {"invisible":true}
var $mistral : cs:C1710.mistral

If (False:C215)
	$mistral:=cs:C1710.mistral.new()  //default
Else 
	var $modelsFolder : 4D:C1709.Folder
	$modelsFolder:=Folder:C1567(fk home folder:K87:24).folder(".mistral-rs")
	var $URL : Text
	var $file : 4D:C1709.File
	If (True:C214)
		//custom model download mode
		$URL:="https://huggingface.co/unsloth/Qwen3-1.7B-GGUF/resolve/main/Qwen3-1.7B-Q5_K_M.gguf"
		$file:=$modelsFolder.file("Qwen3-1.7B-Q5_K_M.gguf")
		$mistral:=cs:C1710.mistral.new($port; $file; $URL; {command: "gguf"}; Formula:C1597(ALERT:C41(This:C1470.file.name+($1.success ? " started!" : " did not start..."))))
	Else 
		//hugging face mode
		$URL:="EricB/Llama-3.2-11B-Vision-Instruct-UQFF"
		$mistral:=cs:C1710.mistral.new($port; Null:C1517; $URL; {command: "vision-plain"}; Formula:C1597(ALERT:C41(This:C1470.file.name+($1.success ? " started!" : " did not start..."))))
	End if 
End if 