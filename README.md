# PSLicense

This is a component to provide a citizen accessing community to purchase licenses for such things as fishing licenses. The component has 2 primary parts:

1. The first part is picking your licenses from a list of configured licenses. Provides the ability to just click on the licenses you need.
2. The second part is paying for the licenses using a payment gateway. To use this capability, the user must request an Authorize.Net sandbox box account [here](https://developer.authorize.net/hello_world/sandbox/). Once the sandbox is setup, the "login" and "transkey" codes must be entered in to the AuthorizeDotNet custom setting.

The following are screenshots of showing citizen selecting licenses from community page and then transitioning to payment screen:

![alt text](https://raw.githubusercontent.com/thedges/PSLicense/master/PSLicenseSnapshot1.png "Sample Image")

Here are the same screens showing accessing the community from browser on mobile phone:

![alt text](https://raw.githubusercontent.com/thedges/PSLicense/master/PSLicenseSnapshot2.png "Sample Image")

This component is driven by information stored in 5 objects. Here is description of the objects:

* <b>PSLicenseType</b> - just stores single text name for license types: "Fishing", etc...

* <b>PSLicenseItem</b> - this is child to above. It is the list of different license variations of that type. Parameters:
  - <b>Name</b> - short name of license
  - <b>Description</b> - description of license
  - <b>License Code</b> - (not used) to store the code or id of a given license type stored in backend system or such
  - <b>License Type</b> - lookup to above parent object
  - <b>Term</b> - number of years, months, days
  - <b>UOM</b> - the unit of measure (years, months, days)
  
* <b>PSPayment</b> (look for Payment) - where the Authorize.Net payment details are stored. Parameters:
  - <b>Type</b> - generic text field to store values like "License", "Permit", etc... 
  - <b>Subtype</b> - generic text field to store values like "Fishing", etc...
  - <b>Status</b> - status of payment
  - <b>Amount</b> - total amount of payment; if you select multiple fishing licenses I will charge the total and create a link for each license (PSLicense) to this payment record
  - <b>Transaction Date</b> - the date of transaction
  - <b>Transaction ID</b> - the id returned from Authorize.Net
  - <b>Transaction Msg</b> - the status/msg string that Authorize.Net sends back

* <b>PSLicense</b> - junction object to store the Licenses purchased by a given Contact; this is object to create related list off the Contact record to show the licenses purchased by a citizen 
  - <b>Contact</b> - the lookup to the contact for which this license is associated to
  - <b>Expires</b> - the date the license expires
  - <b>License Item</b> - the lookup to the PSLicenseItem record
  - <b>Name</b> - a lookup to the Name field on the PSLicenseItem record
  - <b>Payment</b> - a lookup to the PSPayment record that stored the Authorize.Net details
  - <b>Status</b> - the status of the license (Valid, Overdue, Expired)
  - <b>Type</b> - lookup to the License Type name field

* <b>Payment Account</b> - this is the object the drives the account nickname drop-down on the payment screen; you can create bank or credit card default info and attach to a contact.
   - <b>Account Holder Name</b> - the account holder name (for Bank/ACH)
   - <b>Account Nickname</b> - the nickname to show in dropdown list on payment form
   - <b>Account Number</b> - the bank account number (for Bank/ACH)
   - <b>Card Number</b> - the credit card number (for Credit Cards)
   - <b>Contact</b> - a lookup to the contact record to associate this payment account to
   - <b>Expiration Date</b> - the expiration date (for Credit Cards)
   - <b>Name on Card</b> - the name on the card (for Credit Cards)
   - <b>Routing Number</b> - the bank routing number (for Bank/ACH)
   - <b>Security Code</b> - the security code (for Credit Cards)
   - <b>Type</b> - the type of payment account (Bank Account or Credit Card)

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
