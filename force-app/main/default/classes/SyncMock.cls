@isTest
public class SyncMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Simulate the response based on the request
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (req.getEndpoint().contains('/lambda-url')) {
            if (req.getMethod() == 'PATCH') {
                res.setStatusCode(200);
                res.setBody('[{"id":"0031x00000AbCdEF","status":"success"}]');
            } else {
                res.setStatusCode(404);
                res.setBody('{"error":" Not Found"}');
            }
        } else {
            res.setStatusCode(400);
            res.setBody('{"error":" Parameters"}');
        }
        return res;
    }
}
