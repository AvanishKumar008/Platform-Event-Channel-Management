({
    doInit: function (component, event, helper) {
        // Initialize any logic if needed
    },
    handleLabelChange: function (component, event, helper) {
        let name = component.get("v.name");
        let label = component.get("v.label");

        // Only update Name if it is empty
        if (!name && label) {
            let generatedName = helper.generateVariableName(label);
            component.set("v.name", generatedName);
            helper.handleNameValidation(component);
        }
    },
    handleNameBlur: function (component, event, helper) {
        helper.handleNameValidation(component);
    },
    handleSave: function (component, event, helper) {
        let name = component.get("v.name");
        let label = component.get("v.label");
        let type = component.get("v.type");

        if (!name || !label || !type) {
            alert("Please fill out all fields.");
            return;
        }

        // Call Apex to save the record
        let action = component.get("c.createCustomChannel");
        action.setParams({channelProps: {
            name: name,
            label: label,
            type: type
        }});

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            } else {
                alert("Error creating Custom Channel: " + response.getError()[0].message);
            }
        });

        $A.enqueueAction(action);
    },

    handleCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
});
