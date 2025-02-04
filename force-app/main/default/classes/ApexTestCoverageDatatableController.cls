public with sharing class ApexTestCoverageDatatableController {
	@AuraEnabled(cacheable=true)
	public static List<ApexClassCoverageWrapper> getApexTestCoverage() {
		List<ApexClassCoverageWrapper> coverageList = new List<ApexClassCoverageWrapper>();

		// Tooling API Query
		String query = 'SELECT ApexClassOrTriggerId, ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered, LastModifiedById, LastModifiedBy.Name FROM ApexCodeCoverageAggregate';
		RestService callout = new RestService(
				'callout:SF_Auth' + Constant.toolingQueryURL + EncodingUtil.urlEncode(query, 'UTF-8')
			)
			//.setHeaders(Constant.defaultHeaders)
			.setTimeout(60000);
		String response = callout.get().getBody();
		System.debug('response ---------------- ');
		System.debug(response);
		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		if (responseMap.containsKey('records')) {
			List<Object> records = (List<Object>) responseMap.get('records');

			for (Object obj : records) {
				Map<String, Object> record = (Map<String, Object>) obj;
				Decimal numCovered = (Decimal) record.get('NumLinesCovered');
				Decimal numUncovered = (Decimal) record.get('NumLinesUncovered');
				Decimal totalLines = numCovered + numUncovered;
				Decimal coveragePercent = (totalLines > 0) ? (numCovered / totalLines) * 100 : 0;

				ApexClassCoverageWrapper wrapper = new ApexClassCoverageWrapper();
				wrapper.classId = (String) record.get('ApexClassOrTriggerId');
				wrapper.className = (String) ((Map<String, Object>) record.get('ApexClassOrTrigger')).get('Name');
				wrapper.numLinesCovered = (Integer) numCovered;
				wrapper.numLinesUncovered = (Integer) numUncovered;
				wrapper.coveragePercent = coveragePercent;
				wrapper.lastModifiedById = (String) record.get('LastModifiedById');
				wrapper.lastModifiedBy = (String) ((Map<String, Object>) record.get('LastModifiedBy')).get('Name');

				coverageList.add(wrapper);
			}
		}

		return coverageList;
	}

	public class ApexClassCoverageWrapper {
		@AuraEnabled
		public String classId;
		@AuraEnabled
		public String className;
		@AuraEnabled
		public Integer numLinesCovered;
		@AuraEnabled
		public Integer numLinesUncovered;
		@AuraEnabled
		public Decimal coveragePercent;
		@AuraEnabled
		public String lastModifiedById;
		@AuraEnabled
		public String lastModifiedBy;
	}
}
