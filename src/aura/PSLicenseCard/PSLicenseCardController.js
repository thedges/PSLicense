({
	onClick : function(component, event, helper) {
		console.log('onClick...');
		var sel = component.get("v.selected");
		if (sel == true)
		{
           component.set("v.selected", false);
		}
		else
		{
           component.set("v.selected", true);
		}

		var compEvent = component.getEvent("licenseSelectEvent");
        compEvent.fire();
	}
})