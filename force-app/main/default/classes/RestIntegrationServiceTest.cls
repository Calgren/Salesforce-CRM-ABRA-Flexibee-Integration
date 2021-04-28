/**
 * @description Unit Tests for RestIntegrationService class.
 *
 * @author tomaschour
 * @date 2021-04-20
 */
@IsTest
private with sharing class RestIntegrationServiceTest {

    private static final String END_POINT_URL = 'https://google.com';
    private static final String COMPLETE = 'Complete';
    private static final String UNEXPECTED_RESPONSE = 'Unexpected response';

    private static final String VALID_JSON = '{"name": "test", "age": 14}';
    private static final String BAD_JSON = '[{{]';

    /**
     * @description Test implementation allows REST-related functionality to be distributed separately as one piece.
     */
    private with sharing class RestMainObjectTest implements RestMainObject {

        public String name = 'test name';
        public Integer age = 14;

        /**
         * @description For checking if all mandatory fields are set.
         *
         * @return String with errors
         */
        public String checkMandatoryFields() {
            return String.isBlank(name) ? 'name is mandatory' : '';
        }

        /**
         * @description Validates length of input fields.
         *
         * @return String with errors
         */
        public String validateInputs() {
            return age > 0 ? '' : 'age must be above zero';
        }

        /**
         * @description Gives the information out, if bulk-jobs are possible with this object.
         *
         * @return whether bulk jobs are enabled
         */
        public Boolean isBulkPossible() {
            return false;
        }

        /**
         * @description Return the Type of the object.
         *
         * @return Type of the object
         */
        public Type getType() {
            return RestMainObjectTest.class;
        }
    }

    /**
     * @description Checks if the serialization of a list of objects to JSON string works as intended. List of objects.
     */
    @IsTest
    private static void testConvertObjectsToJsonString_nullParam() {
        Test.startTest();
        try {
            RestIntegrationService.convertObjectsToJsonString(null);
            System.assert(false, 'Method should trow RestIntegrationServiceException.');
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the serialization of a list of objects to JSON string works as intended. Invalid inputs.
     */
    @IsTest
    private static void testConvertObjectsToJsonString_InvalidInput() {
        RestMainObjectTest dto = new RestMainObjectTest();
        dto.age = 0;

        Test.startTest();
        try {
            RestIntegrationService.convertObjectsToJsonString(new List<RestMainObject>{
                    dto
            });
            System.assert(false, 'Method should trow RestIntegrationServiceException.');
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
            System.assert(e.getMessage().contains('on record'));
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the serialization of a list of objects to JSON string works as intended. List of objects.
     */
    @IsTest
    private static void testConvertObjectsToJsonString_emptyList() {
        Test.startTest();
        try {
            RestIntegrationService.convertObjectsToJsonString(new List<RestMainObjectTest>());
            System.assert(false, 'Method should trow RestIntegrationServiceException.');
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the serialization of a list of objects to JSON string works as intended. List of objects.
     */
    @IsTest
    private static void testConvertObjectsToJsonString_bigList() {
        Test.startTest();
        try {
            RestIntegrationService.convertObjectsToJsonString(new List<RestMainObjectTest>{
                    new RestMainObjectTest(), new RestMainObjectTest()
            });
            System.assert(false, 'Method should trow RestIntegrationServiceException.');
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the serialization of a list of objects to JSON string works as intended. List of objects.
     */
    @IsTest
    private static void testConvertObjectsToJsonString_mandatoryFieldsMissing() {
        RestMainObjectTest dto = new RestMainObjectTest();
        dto.name = null;

        Test.startTest();
        try {
            RestIntegrationService.convertObjectsToJsonString(new List<RestMainObjectTest>{
                    dto
            });
            System.assert(false, 'Method should trow RestIntegrationServiceException.');
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the serialization of a list of objects to JSON string works as intended. Single object.
     */
    @IsTest
    private static void testConvertSingleObjectToJsonString_nullParam() {
        Test.startTest();
        try {
            RestIntegrationService.convertSingleObjectToJsonString(null);
            System.assert(false, 'Method should trow RestIntegrationServiceException.');
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the 'convertingSingleObjectToJson' method detect missing fields.
     */
    @IsTest
    private static void testConvertSingleObjectToJsonString_mandatoryFieldsMissing() {
        RestMainObjectTest dto = new RestMainObjectTest();
        dto.name = null;

        String reqJson;
        Test.startTest();
        try {
            reqJson = RestIntegrationService.convertSingleObjectToJsonString(dto);
            System.assert(false, 'Method should trow RestIntegrationServiceException.');
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the 'convertingSingleObjectToJson' method detect invalid data.
     */
    @IsTest
    private static void testConvertSingleObjectToJsonString_invalidData() {
        RestMainObjectTest dto = new RestMainObjectTest();
        dto.age = 0;

        String reqJson;
        Test.startTest();
        try {
            reqJson = RestIntegrationService.convertSingleObjectToJsonString(dto);
            System.assert(false, 'Method should trow RestIntegrationServiceException.');
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the deserialization of a list of objects to JSON string is getting correct arguments - nothing to deserialize.
     */
    @IsTest
    private static void testConvertJsonStringIntoObjects_nothingToDeserialize() {
        Test.startTest();
        try {
            RestIntegrationService.convertJsonStringIntoObjects(List<RestMainObjectTest>.class, null);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.NO_OBJECT_OR_JSON));
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the deserialization of a list of objects to JSON string is getting correct arguments - malformed Json.
     */
    @IsTest
    private static void testConvertJsonStringIntoObjects_MalformedJson() {
        Test.startTest();
        try {
            RestIntegrationService.convertJsonStringIntoObjects(List<RestMainObjectTest>.class, BAD_JSON);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.MALFORMED_JSON));
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the deserialization of a list of objects to JSON string is getting correct arguments. Null as type.
     */
    @IsTest
    private static void testConvertJsonStringIntoObjects_NoObjectType() {
        Test.startTest();
        String requestJson = RestIntegrationService.convertObjectsToJsonString(new List<RestMainObjectTest>{
                new RestMainObjectTest()
        });
        try {
            RestIntegrationService.convertJsonStringIntoObjects(null, requestJson);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.NO_OBJECT_OR_JSON));
        }

        Test.stopTest();
    }

    /**
     * @description Check if conversion of JSON string into single object with aid of getType() method works
     */
    @IsTest
    private static void testConvertJsonStringIntoSingleObject() {
        RestMainObjectTest dto = new RestMainObjectTest();
        String jsonString = RestIntegrationService.convertSingleObjectToJsonString(dto);
        Test.startTest();
        RestMainObjectTest convertedDto = (RestMainObjectTest) RestIntegrationService.convertJsonStringIntoSingleObject(dto.getType(), jsonString);
        Test.stopTest();

        System.assertNotEquals(null, convertedDto);
        System.assertEquals(dto.getType(), convertedDto.getType());
        System.assertEquals(dto.name, convertedDto.name);
    }

    /**
     * @description Check if conversion of JSON string into single object with type == null throws relevant exception
     */
    @IsTest
    private static void testConvertJsonStringIntoSingleObject_TypeNull() {
        RestMainObjectTest dto = new RestMainObjectTest();
        Type typeNull = null;
        Boolean exceptionThrown = false;

        String request = RestIntegrationService.convertSingleObjectToJsonString(dto);

        Test.startTest();
        try {
            RestIntegrationService.convertJsonStringIntoSingleObject(typeNull, request);
            System.assert(false);
        } catch (Exception e) {
            exceptionThrown = e.getMessage().contains('to parse not found!');
        }
        Test.stopTest();

        System.assert(exceptionThrown);
    }

    /**
     * @description Check if conversion of JSON string into single object
     * with malformed JSON string throws relevant exception.
     */
    @IsTest
    private static void testConvertJsonStringIntoSingleObject_MalformedJsonString() {
        RestMainObjectTest request = new RestMainObjectTest();
        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            RestIntegrationService.convertJsonStringIntoSingleObject(request.getType(), BAD_JSON);
        } catch (Exception e) {
            exceptionThrown = e.getMessage().contains('JSON string is malformed');
        }
        Test.stopTest();

        System.assert(exceptionThrown);
    }

    /**
     * @description Checks if the serialization of unknown type of object to JSON string works as intended
     */
    @IsTest
    private static void testConvertJsonStringUntyped() {
        Map<String, Object> parsedJsonMap = RestIntegrationService.convertJsonStringUntyped(VALID_JSON);
        System.assertEquals('test', parsedJsonMap.get('name'));
        System.assertEquals(14, parsedJsonMap.get('age'));
    }

    /**
     * @description Checks if the serialization of unknown type of object to JSON string is getting correct arguments
     * - malformed Json
     */
    @IsTest
    private static void testConvertJsonStringUntyped_MalformedJsonString() {
        Boolean exceptionThrown = false;
        try {
            RestIntegrationService.convertJsonStringUntyped(BAD_JSON);
            System.assert(false);
        } catch (Exception e) {
            exceptionThrown = e.getMessage().contains('JSON string is malformed');
        }
        System.assert(exceptionThrown);
    }

    /**
     * @description Checks that  we cant get http request without specifying method.
     */
    @IsTest
    private static void testGetHttpRequest_EmptyRequestMethod() {
        Test.startTest();
        try {
            RestIntegrationService.getHttpRequest(null, null, BAD_JSON, null, END_POINT_URL);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.INVALID_INFO));
        }
        Test.stopTest();
    }

    /**
     * @description Checks that we cant get http request without providing an endpoint.
     */
    @IsTest
    private static void testGetHttpRequest_EmptyCredentials() {
        Test.startTest();
        try {
            RestIntegrationService.getHttpRequest(null, null, '{}', null, null);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.INVALID_INFO));
        }
        Test.stopTest();
    }

    /**
     * @description Checks that we need to provide body, if we are creating POST http request.
     */
    @IsTest
    private static void testGetHttpRequest_EmptyBodyPost() {
        Test.startTest();
        try {
            RestIntegrationService.getHttpRequest(null, RestIntegrationService.HttpMethod.POST, null, null, END_POINT_URL);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.POST_METHOD_NO_BODY));
        }
        Test.stopTest();
    }

    /**
     * @description Checks if the serialization of a list of objects to JSON string works as intended.
     * Conversion of valid list should equal to the conversion of one single valid object.
     */
    @IsTest
    private static void testConvertObjectToJsonString_oneItemAsSingleObj() {
        List<RestMainObjectTest> dtos = new List<RestMainObjectTest>{
                new RestMainObjectTest()
        };

        Test.startTest();
        String reqJson1 = RestIntegrationService.convertObjectsToJsonString((List<RestMainObject>) dtos);
        String reqJson2 = RestIntegrationService.convertSingleObjectToJsonString((RestMainObject) dtos.get(0));
        Test.stopTest();

        System.assert(reqJson1.contains(reqJson2));
    }

    /**
     * @description Checks that we can call a web service and receive and parse the answer
     */
    @IsTest
    private static void testCallWebService() {
        String requestBody = RestIntegrationService.convertSingleObjectToJsonString(new RestMainObjectTest());

        HttpRequest request = RestIntegrationService.getHttpRequest(RestIntegrationService.HttpMethod.GET, requestBody, null, END_POINT_URL);
        RestHttpResponseMock fakeResponse = new RestHttpResponseMock(200, COMPLETE, VALID_JSON, null);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        HttpResponse response = RestIntegrationService.callWebService(request);
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals(200, response.getStatusCode());
        System.assertEquals(COMPLETE, response.getStatus());
        System.assertEquals(VALID_JSON, response.getBody());
    }

    /**
     * @description Checks that we can handle trying to send request without providing request
     */
    @IsTest
    private static void testCallWebService_NoRequest() {
        RestHttpResponseMock fakeResponse = new RestHttpResponseMock(200, COMPLETE, VALID_JSON, null);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        try {
            RestIntegrationService.callWebService(null);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof RestIntegrationService.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.NO_REQUEST));
        }
        Test.stopTest();
    }

    /**
     * @description Checks that we can handle wrong status code during the call
     */
    @IsTest
    private static void testCallWebService_WrongStatusCode() {
        HttpRequest request = RestIntegrationService.getHttpRequest(RestIntegrationService.HttpMethod.GET, '{}', null, END_POINT_URL);
        RestHttpResponseMock fakeResponse = new RestHttpResponseMock(400, UNEXPECTED_RESPONSE, VALID_JSON, null);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        HttpResponse res = RestIntegrationService.callWebService(request);

        System.assert(res != null);
        System.assertEquals(400, res.getStatusCode());
        System.assertEquals(UNEXPECTED_RESPONSE, res.getStatus());
        System.assertEquals(VALID_JSON, res.getBody());
        Test.stopTest();
    }


    /**
    * @description Tests creating http request with specified method and endpoint
    */
    @IsTest
    private static void testGetHttpRequest_methodEndpoint() {
        Test.startTest();
        HttpRequest request = RestIntegrationService.getHttpRequest(RestIntegrationService.HttpMethod.GET, END_POINT_URL);
        Test.stopTest();
        System.assertEquals(END_POINT_URL, request.getEndpoint());
        System.assertEquals(RestIntegrationService.HttpMethod.GET.name(), request.getMethod());
    }

    /**
    * @description Tests creating http request with specified headers, method and endpoint
    */
    @IsTest
    private static void testGetHttpRequest_headersMethodEndpoint() {
        Test.startTest();
        HttpRequest request = RestIntegrationService.getHttpRequest(new Map<String, String>{
                'Content-Type' => 'multipart/form-data; boundary=something',
                'Connection' => 'close'
        },
                RestIntegrationService.HttpMethod.GET, END_POINT_URL);
        Test.stopTest();
        System.assertEquals(END_POINT_URL, request.getEndpoint());
        System.assertEquals(RestIntegrationService.HttpMethod.GET.name(), request.getMethod());
        System.assertEquals('multipart/form-data; boundary=something', request.getHeader('Content-Type'));
        System.assertEquals('close', request.getHeader('Connection'));
    }


    /**
    * @description Tests creating http request with specified headers, method, body and endpoint
    */
    @IsTest
    private static void testGetHttpRequest_headersMethodBodyEndpoint() {
        Test.startTest();
        HttpRequest request = RestIntegrationService.getHttpRequest(new Map<String, String>{
                'Content-Type' => 'multipart/form-data; boundary=something',
                'Connection' => 'close'
        },
                RestIntegrationService.HttpMethod.GET, VALID_JSON, END_POINT_URL);
        Test.stopTest();
        System.assertEquals(END_POINT_URL, request.getEndpoint());
        System.assertEquals(RestIntegrationService.HttpMethod.GET.name(), request.getMethod());
        System.assertEquals(VALID_JSON, request.getBody());
        System.assertEquals('multipart/form-data; boundary=something', request.getHeader('Content-Type'));
        System.assertEquals('close', request.getHeader('Connection'));
    }


    /**
    * @description Tests creating http request with specified method, body and endpoint
    */
    @IsTest
    private static void testGetHttpRequest_methodBodyEndpoint() {
        Test.startTest();
        HttpRequest request = RestIntegrationService.getHttpRequest(
                RestIntegrationService.HttpMethod.GET, VALID_JSON, END_POINT_URL);
        Test.stopTest();
        System.assertEquals(END_POINT_URL, request.getEndpoint());
        System.assertEquals(RestIntegrationService.HttpMethod.GET.name(), request.getMethod());
        System.assertEquals(VALID_JSON, request.getBody());
        System.assertEquals(RestIntegrationService.DEFAULT_HEADERS.get('Content-Type'), request.getHeader('Content-Type'));
        System.assertEquals(RestIntegrationService.DEFAULT_HEADERS.get('Connection'), request.getHeader('Connection'));
    }
}
