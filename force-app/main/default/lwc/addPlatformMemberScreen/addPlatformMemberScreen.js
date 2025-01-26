import { LightningElement, wire, api } from "lwc";
import getInitialDetails from "@salesforce/apex/AddPlatformMemberScreenController.getInitialDetails";

export default class AddPlatformMemberScreen extends LightningElement {
  @api recordId
  customChannel = {};
  objects = [];
  selectedObjects = [];
  newSelectedObjects = [];

  @wire(getInitialDetails, {recordId : '$recordId'})
  wiredContacts({ error, data }) {
    console.log("data", data);
    console.log("error", error);
    if (data) {
      this.objects = data.options;
      this.selectedObjects = data.selectedOption;
      this.customChannel = data.customChannel;
    } else if (error) {
      this.objects = [];
      this.selectedObjects = [];
    }
  }

  handleMemberChange(event) {
    this.newSelectedObjects = event.detail.value;
  }
}