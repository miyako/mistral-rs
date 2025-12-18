property port : Integer
property onData : 4D:C1709.Function
property onDataError : 4D:C1709.Function
property onTerminate : 4D:C1709.Function

Class extends _CLI

Class constructor($controller : 4D:C1709.Class)
	
	If (Not:C34(OB Instance of:C1731($controller; cs:C1710._mistral_Controller)))
		$controller:=cs:C1710._mistral_Controller
	End if 
	
	var $program : Text
	
	Case of 
		: (Is macOS:C1572) && (System info:C1571.processor#"@Apple@")
			$program:="mistralrs-server-x86_64"
		Else 
			$program:="mistralrs-server"
	End case 
	
	Super:C1705($program; $controller)
	
Function bind($option : Object; $properties : Collection) : cs:C1710._mistral
	
	var $property : Text
	For each ($property; $properties)
		This:C1470[$property]:=$option[$property]
	End for each 
	
	return This:C1470
	
Function get worker() : 4D:C1709.SystemWorker
	
	return This:C1470.controller.worker
	
Function terminate()
	
	This:C1470.controller.terminate()