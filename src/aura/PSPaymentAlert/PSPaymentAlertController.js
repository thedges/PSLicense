({
	doInit : function(component, event, helper) {
		console.log('doInit fired...');
        helper.getTaxDue(component);
	},
	btnPayTax : function(component, event, helper) {
		console.log('btnPayTax fired...');
		component.set("v.showPayment", true);
	}
})