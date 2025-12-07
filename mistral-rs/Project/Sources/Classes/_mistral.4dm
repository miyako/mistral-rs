Class extends _CLI

Class constructor($command : Text; $controller : 4D:C1709.Class)
	
	If (Not:C34(OB Instance of:C1731($controller; cs:C1710._mistral_Controller)))
		$controller:=cs:C1710._mistral_Controller
	End if 
	
	var $program : Text
	
	var $program : Text
	Case of 
		: (Is macOS:C1572) && (Get system info:C1571.processor#"@Apple@")
			$program:="mistralrs-server-x86_64"
		Else 
			$program:="mistralrs-server"
	End case 
	
	Super:C1705($program; $controller)
	
Function get worker() : 4D:C1709.SystemWorker
	
	return This:C1470.controller.worker
	
Function terminate()
	
	This:C1470.controller.terminate()