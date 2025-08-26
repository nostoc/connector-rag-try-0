import ballerina/ai;
import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service / on httpDefaultListener {

    resource function post query(@http:Payload string userQuery) returns json|error {
        ai:QueryMatch[] context = check knowledgeBase.retrieve(userQuery);
        ai:ChatUserMessage augmenteduserMsg = ai:augmentUserQuery(context, userQuery);
        string response = check defaultModel->generate(check augmenteduserMsg.content.ensureType());
        return response;
    }
}
