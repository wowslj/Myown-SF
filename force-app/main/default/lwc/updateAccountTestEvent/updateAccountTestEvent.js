import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from "lightning/empApi";
export default class toastDemo extends LightningElement {
  channelName = "/event/Account_Update__e";

  @api recordId;

  get changedRecordId() {
    return this.targetedRecordId;
  }

  subscription = {};

  // Initializes the component
  connectedCallback() {
    // Register error listener
    this.registerErrorListener();
    const currentRecordId = this.recordId;
    const context = this;
    const messageCallback = function (response) {
      // Response contains the payload of the new message received
      let event = response.data.payload;

      if (event.Account_Id__c == currentRecordId) {
        const evt = new ShowToastEvent({
          message: "Name contains ssss",
          variant: "info"
        });
        context.dispatchEvent(evt);
      }
    };

    // Invoke subscribe method of empApi. Pass reference to messageCallback
    subscribe(this.channelName, -1, messageCallback).then((response) => {
      // Response contains the subscription information on subscribe call
      console.log("Subscription request sent to: ", JSON.stringify(response.channel));
      this.subscription = response;
    });
  }

  disconnectedCallback() {
    unsubscribe(this.subscription, (unsubResp) => {
      console.log("unsubscribe() response: ", JSON.stringify(unsubResp));
    });
  }

  registerErrorListener() {
    // Invoke onError empApi method
    onError((error) => {
      console.log("Received error from server: ", JSON.stringify(error));
      // Error contains the server-side error
    });
  }
}