Class constructor($port : Integer; $file : 4D:C1709.File; $URL : Text; $options : Object; $formula : 4D:C1709.Function)
	
	var $mistral : cs:C1710._worker
	$mistral:=cs:C1710._worker.new()
	
	If (Not:C34($mistral.isRunning($port)))
		
		If (Value type:C1509($file)#Is object:K8:27) || (Not:C34(OB Instance of:C1731($file; 4D:C1709.File))) || ($URL="")
			var $modelsFolder : 4D:C1709.Folder
			$modelsFolder:=Folder:C1567(fk home folder:K87:24).folder(".mistral-rs")
		End if 
		
		If ($port=0) || ($port<0) || ($port>65535)
			$port:=8080
		End if 
		
		CALL WORKER:C1389(OB Class:C1730(This:C1470).name; This:C1470._Start; $port; $file; $URL; $options; $formula)
		
	End if 
	
Function _Start($port : Integer; $file : 4D:C1709.File; $URL : Text; $options : Object; $formula : 4D:C1709.Function)
	
	var $model : cs:C1710.Model
	$model:=cs:C1710.Model.new($port; $file; $URL; $options; $formula)
	
Function terminate()
	
	var $mistral : cs:C1710._worker
	$mistral:=cs:C1710._worker.new()
	$mistral.terminate()