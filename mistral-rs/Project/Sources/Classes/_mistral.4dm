property port : Integer
property onData : 4D:C1709.Function
property onDataError : 4D:C1709.Function
property onTerminate : 4D:C1709.Function

Class extends _CLI

Class constructor($class : 4D:C1709.Class)
	
	var $controller : 4D:C1709.Class
	var $superclass : 4D:C1709.Class
	$superclass:=$class.superclass
	$controller:=cs:C1710._mistral_Controller
	
	While ($superclass#Null:C1517)
		If ($superclass=$controller)
			$controller:=$class
			break
		End if 
		$superclass:=$superclass.superclass
	End while 
	
	var $program : Text
	
	Case of 
		: (Is macOS:C1572) && (System info:C1571.processor#"@Apple@")
			$program:="mistralrs-server-x86_64"
		Else 
			$program:="mistralrs-server"
	End case 
	
	Super:C1705($program; $controller)
	
Function bind($option : Object; $properties : Collection) : cs:C1710._CLI
	
	var $property : Text
	For each ($property; $properties)
		This:C1470[$property]:=$option[$property]
	End for each 
	
	return This:C1470
	
Function get worker() : 4D:C1709.SystemWorker
	
	return This:C1470.controller.worker
	
Function terminate()
	
	This:C1470.controller.terminate()