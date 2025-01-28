import { LightningElement, wire, api } from "lwc";
import Toast from 'lightning/toast';

import getInitialDetails from "@salesforce/apex/AddPlatformMemberScreenController.getInitialDetails";
import createAndRemoveChannelMember from "@salesforce/apex/AddPlatformMemberScreenController.createAndRemoveChannelMember";

export default class AddPlatformMemberScreen extends LightningElement {
  @api recordId
  customChannel = {};
  objects = [];
  selectedObjects = [];
  newSelectedObjects = [];

  @wire(getInitialDetails, {recordId : '$recordId'})
  wiredContacts({ error, data }) {
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

  handleSaveMember(){
    let objectToBeAdded = this.newSelectedObjects.filter((e) => !this.selectedObjects.includes(e));
    let objectToBeRemoved = this.selectedObjects.filter((e) => !this.newSelectedObjects.includes(e));
    console.log('objectToBeAdded',objectToBeAdded);
    console.log('objectToBeRemoved',objectToBeRemoved);

		createAndRemoveChannelMember({ customChannel : this.customChannel, memberToBeAdded : objectToBeAdded, memberToBeRemoved : objectToBeRemoved })
		.then(() => {
      this.selectedObjects = this.newSelectedObjects;
        Toast.show({
          label: 'Success',
          message: 'Member Added/Removal Done successfully',
          variant: 'success'
      }, this);
		})
		.catch(error => {
			console.log('createAndRemoveChannelMember error',error);
		})
  }
}