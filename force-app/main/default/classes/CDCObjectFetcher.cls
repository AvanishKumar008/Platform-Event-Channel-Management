public class CDCObjectFetcher {
    public static List<String> getCDCEnabledObjects() {
        List<String> cdcObjects = new List<String>();
        
        // Get all global describe
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        
        // Iterate through all objects
        for(String objName : globalDescribe.keySet()) {
            // Check if the object name ends with 'ChangeEvent'
            if(objName.toLowerCase().endsWith('changeevent')) {
                // Remove 'ChangeEvent' suffix to get the original object name
                String originalObjName = objName.toLowerCase().replace('__changeevent', '__c').removeEnd('changeevent');
                cdcObjects.add(originalObjName);
            }
        }
        
        cdcObjects.sort();
        return cdcObjects;  // Return sorted list for better readability
    }
    
    // Method to print CDC enabled objects with additional details
    public static void printCDCEnabledObjects() {
        List<String> objects = getCDCEnabledObjects();
        System.debug('=== CDC Enabled Objects ===');
        System.debug('Total Objects with CDC enabled: ' + objects.size());
        System.debug('Objects:');
        for(String obj : objects) {
            // Get the object describe to show label
            Schema.DescribeSObjectResult describe = Schema.getGlobalDescribe().get(obj).getDescribe();
            System.debug('- ' + describe.getName() + ' (' + describe.getLabel() + ')');
        }
    }
    
    // Method to get CDC objects with their labels
    public static Map<String, String> getCDCEnabledObjectsWithLabels() {
        Map<String, String> objectsWithLabels = new Map<String, String>();
        
        for(String objName : getCDCEnabledObjects()) {
            Schema.DescribeSObjectResult describe = Schema.getGlobalDescribe().get(objName).getDescribe();
            objectsWithLabels.put(objName, describe.getLabel());
        }
        
        return objectsWithLabels;
    }
}