({
	/**
	 * Generates a valid variable name from the label text.
	 * @param {String} label - The input label.
	 * @returns {String} - The transformed name.
	 */
	generateVariableName: function (label) {
		if (!label) {
			return '';
		}

		// Replace invalid characters with underscores
		let name = label.replace(/[^a-zA-Z0-9]/g, '_');

		// Replace multiple underscores with a single underscore
		name = name.replace(/_+/g, '_');

		// Remove leading or trailing underscores
		name = name.replace(/^_+|_+$/g, '');

		return name.length > 35 ? name.substring(0, 35) : name;
	},
	handleNameValidation: function (component) {
		let nameInput = component.find('nameInput');

		// Validate Name using validity property and custom logic
		let name = component.get('v.name');
		if (!this.isNameValid(name)) {
			nameInput.setCustomValidity(
				'Name is invalid. It should only contain letters, numbers, and underscores, and should not start or end with underscores.'
			);
		} else {
			nameInput.setCustomValidity(''); // Clear any custom error message
		}

		// Report validity to show errors visually if invalid
		nameInput.reportValidity();
	},

	/**
	 * Validates the Name field format.
	 * @param {String} name - The input name.
	 * @returns {Boolean} - True if valid, otherwise false.
	 */
	isNameValid: function (name) {
		if (!name) {
			return false;
		}

		// Check for invalid characters or double underscores
		let validPattern = /^[a-zA-Z0-9_]+$/;
		if (!validPattern.test(name)) {
			return false;
		}

		// Ensure no leading or trailing underscores
		if (name.startsWith('_') || name.endsWith('_')) {
			return false;
		}

		// Check for double underscores
		if (name.includes('__')) {
			return false;
		}

		return true;
	}
});
