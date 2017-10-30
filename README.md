# PSLicense

This is a component to provide a "launcher" type app that is similar to the one at San Diego's [Get It Done](https://www.sandiego.gov/) site.  The focus of the component is 3 parts:

1. What is your "need"
2. The actions/options associated to the need you selected
3. An information page with a description line of the action/option, optional details for the action, and a button to launch to the service

The following is example screen showing the 3 pieces of this "launcher" component. The two left-hand images show the component in a normal Community template and the right-hand image is same accessed from mobile app.

![alt text](https://raw.githubusercontent.com/thedges/PSLicense/master/PSLicenseSnapshot1.png "Sample Image")

![alt text](https://raw.githubusercontent.com/thedges/PSLicense/master/PSLicenseSnapshot2.png "Sample Image")

This component is driven by information stored in 2 objects. Here is description of the objects:

It is driven off these objects:

* <b>PSLicenseType</b> - just stores single text name for license types: "Fishing", etc...

* <b>PSLicenseItem</b> - this is child to above. It is the list of different license variations of that type. Parameters:
  - <b>Name</b> - short name of license
  - <b>Description</b> - description of license
  - <b>License Code</b> - (not used) but figured my keep a code or id of a given license type stored in backend system or such
  - <b>License Type</b> - lookup to above parent object
  - <b>Term</b> - number of years, months, days
  - <b>UOM</b> - the unit of measure (years, months, days)
  
* <b>PSPayment</b> (look for Payment) - where I stored Authorize.Net payment details Parameters:
  - <b>Type</b> - generic text field to store values like "License", "Permit", etc... 
  - <b>Subtype</b> - generic text field to store values like "Fishing", etc...
  - <b>Status</b> - status of payment
  - <b>Amount</b> - total amount of payment; if you select multiple fishing licenses I will charge the total and create a link for each license (PSLicense) to this payment record
  - <b>Transaction Date</b> - the date of transaction
  - <b>Transaction ID</b> - the id returned from Authorize.Net
  - <b>Transaction Msg</b> - the status/msg string that Authorize.Net sends back

* <b>PSLicense</b> - junction object to store the Licenses purchased by a given Contact; this is object 

* <b>PSPaymentAccount</b> - this is the object the drives the account nickname drop-down on the payment screen; you can create bank or credit card default info and attach to a contact

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
