import { LightningElement, wire, api } from 'lwc';
import Toast from 'lightning/toast';
import { refreshApex } from '@salesforce/apex';

import getInitialDetails from '@salesforce/apex/AddPlatformMemberScreenController.getInitialDetails';
import createAndRemoveChannelMember from '@salesforce/apex/AddPlatformMemberScreenController.createAndRemoveChannelMember';

export default class AddPlatformMemberScreen extends LightningElement {
	@api recordId;
	customChannel = {};
	objects = [];
	selectedObjects = [];
	newSelectedObjects = [];
	wireInitData;

	@wire(getInitialDetails, { recordId: '$recordId' })
	wiredInitData(result) {
		this.wireInitData = result;
		if (result.data) {
			this.objects = result.data.options;
			this.selectedObjects = result.data.selectedOption;
			this.customChannel = result.data.customChannel;
		} else if (result.error) {
			this.objects = [];
			this.selectedObjects = [];
		}
	}

	get inProgressRequest() {
		return this.customChannel && this.customChannel.Member_Update_Status__c === 'Pending';
	}

	get errorRequest() {
		return this.customChannel && this.customChannel.Member_Update_Status__c === 'Error';
	}

	refreshLatestData() {
		refreshApex(this.wireInitData);
	}

	handleMemberChange(event) {
		this.newSelectedObjects = event.detail.value;
	}

	handleSaveMember() {
		let objectToBeAdded = this.newSelectedObjects.filter((e) => !this.selectedObjects.includes(e));
		let objectToBeRemoved = this.selectedObjects.filter((e) => !this.newSelectedObjects.includes(e));

		createAndRemoveChannelMember({
			customChannel: this.customChannel,
			memberToBeAdded: objectToBeAdded,
			memberToBeRemoved: objectToBeRemoved
		})
			.then(() => {
				this.selectedObjects = this.newSelectedObjects;
				this.refreshLatestData();
				Toast.show(
					{
						label: 'Success',
						message: 'Member Added/Removal successfully started',
						variant: 'success'
					},
					this
				);
			})
			.catch((error) => {
				console.log('createAndRemoveChannelMember error', error);
			});
	}
}
