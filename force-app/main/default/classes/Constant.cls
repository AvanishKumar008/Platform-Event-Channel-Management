public class Constant {
    public static String baseURL = URL.getOrgDomainUrl().toExternalForm();
    public static Map<String,String> defaultHeaders = new Map<String,String>{
            'Authorization' => 'Bearer '+UserInfo.getSessionId(),
            'Content-Type' => 'application/json; charset=utf-8'
            };
    public static String toolingQueryURL = '/services/data/v61.0/tooling/query?q=';
    public static String toolingsObjectURL = '/services/data/v61.0/tooling/sobjects/';
}