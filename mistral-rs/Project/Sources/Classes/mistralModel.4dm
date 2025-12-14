property model_id : Text
property chat_template : Text
property jinja_explicit : 4D:C1709.File
property num_device_layers : Integer
property in_situ_quant : Text

Class extends _model

Class constructor($file : 4D:C1709.File; \
$URL : Text; \
$model_id : Text; \
$jinja_explicit : 4D:C1709.File; \
$chat_template : Text; \
$num_device_layers : Integer; \
$in_situ_quant : Text)
	
	Super:C1705($file; $URL)
	
	This:C1470.model_id:=$model_id
	This:C1470.jinja_explicit:=$jinja_explicit
	This:C1470.chat_template:=$chat_template
	This:C1470.num_device_layers:=$num_device_layers
	This:C1470.in_situ_quant:=$in_situ_quant
	