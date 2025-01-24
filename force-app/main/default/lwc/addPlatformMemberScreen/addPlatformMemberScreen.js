import { LightningElement, wire } from "lwc";
import getObjectDetails from "@salesforce/apex/AddPlatformMemberScreenController.getObjectDetails";

export default class AddPlatformMemberScreen extends LightningElement {
  objects = [];
  selectedObjects = [];

  @wire(getObjectDetails)
  wiredContacts({ error, data }) {
    console.log("data", data);
    console.log("error", error);
    if (data) {
      this.objects = data.options;
      this.selectedObjects = data.selectedOption;
    } else if (error) {
      this.objects = [];
      this.selectedObjects = [];
    }
  }

  handleMemberChange(event) {
    this.selectedObjects = event.detail.value;
  }
}