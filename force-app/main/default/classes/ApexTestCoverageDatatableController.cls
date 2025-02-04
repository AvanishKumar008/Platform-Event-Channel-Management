public with sharing class ApexTestCoverageDatatableController {
	@AuraEnabled(cacheable=true)
	public static List<ApexClassCoverageWrapper> getApexTestCoverage() {
		List<ApexClassCoverageWrapper> coverageList = new List<ApexClassCoverageWrapper>();

		// Querying ApexCodeCoverageAggregate via Tooling API
		/*String query =
			'SELECT ApexClassOrTriggerId, ApexClassOrTrigger.Name, NumLinesCovered, ' +
			'NumLinesUncovered, LastModifiedById, LastModifiedBy.Name ' +
			'FROM ApexCodeCoverageAggregate';

		List<ToolingAPI.QueryResult> results = ToolingAPI.query(query);
		if (results != null && !results.isEmpty()) {
			for (ToolingAPI.QueryResult result : results) {
				ToolingAPI.SObject record = result.records[0];

				Decimal totalLines =
					(record.get('NumLinesCovered') != null ? (Decimal) record.get('NumLinesCovered') : 0) +
					(record.get('NumLinesUncovered') != null ? (Decimal) record.get('NumLinesUncovered') : 0);
				Decimal coveragePercent = (totalLines > 0)
					? ((Decimal) record.get('NumLinesCovered') / totalLines) * 100
					: 0;

				coverageList.add(
					new ApexClassCoverageWrapper(
						(String) record.get('ApexClassOrTriggerId'),
						(String) record.get('ApexClassOrTrigger.Name'),
						(Integer) record.get('NumLinesCovered'),
						(Integer) record.get('NumLinesUncovered'),
						coveragePercent,
						(String) record.get('LastModifiedById'),
						(String) record.get('LastModifiedBy.Name')
					)
				);
			}
		}*/
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

		public ApexClassCoverageWrapper(
			String classId,
			String className,
			Integer numLinesCovered,
			Integer numLinesUncovered,
			Decimal coveragePercent,
			String lastModifiedById,
			String lastModifiedBy
		) {
			this.classId = classId;
			this.className = className;
			this.numLinesCovered = numLinesCovered;
			this.numLinesUncovered = numLinesUncovered;
			this.coveragePercent = coveragePercent;
			this.lastModifiedById = lastModifiedById;
			this.lastModifiedBy = lastModifiedBy;
		}
	}
}
