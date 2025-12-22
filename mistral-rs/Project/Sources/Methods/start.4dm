//%attributes = {"invisible":true,"preemptive":"capable"}
#DECLARE($options : Object; $formula : 4D:C1709.Function)

var $model : cs:C1710._Model_
$model:=cs:C1710._Model_.new($options.port; $options.models; $options.options; $formula; $options.event)