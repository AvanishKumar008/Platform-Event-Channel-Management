/***********************************************************************************************
 * This file is part of the Apex Callouts project, released under the MIT License.              *
 * See LICENSE file or go to https://github.com/jongpie/ApexCallouts for full license details.  *
 ***********************************************************************************************/

public inherited sharing class RestService {
	private String endpoint;
	private Map<String, String> headers;
	private Map<String, String> parameters;
	@testVisible
	private HttpRequest request;

	//Constructor
	public RestService(String namedCredential, String endpointPath) {
		this();
		this.endpoint = 'callout:' + namedCredential + endpointPath;
	}

	public RestService(String endpoint) {
		this();
		this.endpoint = endpoint;
	}

	private RestService() {
		this.headers = new Map<String, String>();
		this.parameters = new Map<String, String>();
		this.request = new HttpRequest();
	}

	public RestService setClientCertificateName(String clientCertificateName) {
		this.request.setClientCertificateName(clientCertificateName);
		return this;
	}

	public RestService setCompressed() {
		return this.setCompressed(true);
	}

	public RestService setCompressed(Boolean compress) {
		this.request.setCompressed(compress);
		return this;
	}

	public RestService setHeader(String key, String value) {
		this.setHeaders(new Map<String, String>{ key => value });
		return this;
	}

	public RestService setHeaders(Map<String, String> headers) {
		this.headers.putAll(headers);
		return this;
	}

	public RestService setParameter(String key, String value) {
		this.setParameters(new Map<String, String>{ key => value });
		return this;
	}

	public RestService setParameters(Map<String, String> parameters) {
		this.parameters.putAll(parameters);
		return this;
	}

	public RestService setTimeout(Integer timeoutMs) {
		this.request.setTimeout(timeoutMs);
		return this;
	}

	public HttpResponse del() {
		// 'DELETE' is a reserved word in Apex, so method name has been abbreviated
		return this.executeCallout('DELETE', null);
	}

	public HttpResponse get() {
		return this.executeCallout('GET', null);
	}

	public HttpResponse head() {
		return this.executeCallout('HEAD', null);
	}

	public HttpResponse patch() {
		return this.patch(null);
	}

	public HttpResponse patch(Object requestBody) {
		return this.executeCallout('PATCH', requestBody);
	}

	public HttpResponse post() {
		return this.post(null);
	}

	public HttpResponse post(Object requestBody) {
		return this.executeCallout('POST', requestBody);
	}

	public HttpResponse put() {
		return this.put(null);
	}

	public HttpResponse put(Object requestBody) {
		return this.executeCallout('PUT', requestBody);
	}

	public HttpResponse trace() {
		return this.executeCallout('TRACE', null);
	}

	private HttpResponse executeCallout(String httpVerb, Object requestBody) {
		this.request.setMethod(httpVerb);
		this.setHeaders();
		this.setEndpointAndParameters();
		this.setRequestBody(requestBody);

		HttpResponse response = new Http().send(this.request);
		return response;
	}

	private void setHeaders() {
		for (String headerKey : this.headers.keySet()) {
			this.request.setHeader(headerKey, this.headers.get(headerKey));
		}
	}

	private void setEndpointAndParameters() {
		String parameterString = '';
		for (String parameterKey : this.parameters.keySet()) {
			String paremeterDelimiter = String.isEmpty(parameterString) &&
				!this.endpoint.contains('?')
				? '?'
				: '&';
			parameterString +=
				paremeterDelimiter +
				parameterKey +
				'=' +
				this.parameters.get(parameterKey);
		}
		this.request.setEndpoint(this.endpoint + parameterString);
	}

	private void setRequestBody(Object requestBody) {
		if (requestBody == null) {
			return;
		}

		// Determine if the content type has already been set
		// If it's null, then it will be automatically set based on the request body
		Boolean contentTypeNotSet = this.headers.get('Content-Type') == null;

		if (requestBody instanceof Blob) {
			this.request.setBodyAsBlob((Blob) requestBody);
			if (contentTypeNotSet) {
				this.setHeader(
					'Content-Type',
					'multipart/form-data; charset=utf-8'
				);
			}
		} else if (requestBody instanceof Dom.Document) {
			this.request.setBodyDocument((Dom.Document) requestBody);
			if (contentTypeNotSet) {
				this.setHeader('Content-Type', 'text/xml; charset=utf-8');
			}
		} else {
			this.request.setBody(Json.serialize(requestBody));
			if (contentTypeNotSet) {
				this.setHeader(
					'Content-Type',
					'application/json; charset=utf-8'
				);
			}
		}
	}
}
