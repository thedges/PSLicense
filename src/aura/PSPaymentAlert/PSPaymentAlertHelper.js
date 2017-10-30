({
	getTaxDue: function(component) {
        console.log('getTaxDue started...');

        var action = component.get("c.getTaxDue");

        var self = this;
        action.setCallback(this, function(a) {
            console.log('query callback!');
            var ret = a.getReturnValue();
            component.set("v.amount", ret.amount);
            component.set("v.dueDate", ret.dueDate);
        });
        $A.enqueueAction(action);
        
    }
})