import { LightningElement, wire, track } from 'lwc';
import getApexTestCoverage from '@salesforce/apex/ApexTestCoverageDatatableController.getApexTestCoverage';

export default class ApexTestCoverageDatatable extends LightningElement {
	@track data = [];
	@track filteredData = [];
	@track sortBy;
	@track sortDirection = 'asc';

	columns = [
		{
			label: 'Class Name',
			fieldName: 'classLink',
			type: 'url',
			typeAttributes: { label: { fieldName: 'className' }, target: '_blank' },
			sortable: true
		},
		{ label: 'Lines Covered', fieldName: 'numLinesCovered', type: 'number', sortable: true },
		{ label: 'Lines Uncovered', fieldName: 'numLinesUncovered', type: 'number', sortable: true },
		{
			label: 'Coverage (%)',
			fieldName: 'coveragePercent',
			type: 'percent',
			sortable: true,
			cellAttributes: { class: { fieldName: 'coverageColor' } }
		},
		{
			label: 'Last Modified By',
			fieldName: 'lastModifiedByLink',
			type: 'url',
			typeAttributes: { label: { fieldName: 'lastModifiedBy' }, target: '_blank' },
			sortable: true
		}
	];

	@wire(getApexTestCoverage)
	wiredData({ error, data }) {
		if (data) {
			this.data = data.map((row) => ({
				...row,
				classLink: `/lightning/r/ApexClass/${row.classId}/view`,
				lastModifiedByLink: `/lightning/r/User/${row.lastModifiedById}/view`,
				coverageColor:
					row.coveragePercent >= 75
						? 'slds-text-color_success'
						: row.coveragePercent >= 50
							? 'slds-text-color_warning'
							: 'slds-text-color_error'
			}));
			this.filteredData = [...this.data];
		} else if (error) {
			console.error('Error fetching Apex coverage:', error);
		}
	}

	handleSort(event) {
		this.sortBy = event.detail.fieldName;
		this.sortDirection = event.detail.sortDirection;
		this.sortData();
	}

	sortData() {
		let sortedData = [...this.filteredData];
		sortedData.sort((a, b) => {
			let valueA = a[this.sortBy];
			let valueB = b[this.sortBy];
			return this.sortDirection === 'asc' ? (valueA > valueB ? 1 : -1) : valueA < valueB ? 1 : -1;
		});
		this.filteredData = sortedData;
	}

	handleFilter(event) {
		const searchKey = event.target.value.toLowerCase();
		this.filteredData = this.data.filter((row) => row.className.toLowerCase().includes(searchKey));
	}

	get formattedData() {
		return this.filteredData;
	}
}
