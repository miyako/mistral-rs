property model_id : Text
property model : Text
property options : Object

Class extends _model

Class constructor($file : 4D:C1709.File; \
$URL : Text; \
$model_id : Text; \
$model : Text; \
$options : Object)
	
	Super:C1705($file; $URL)
	
	This:C1470.model_id:=$model_id
	This:C1470.model:=$model
	This:C1470.options:=$options