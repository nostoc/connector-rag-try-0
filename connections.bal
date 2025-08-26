import ballerinax/ai.pinecone;
import ballerina/ai;

final pinecone:VectorStore pineConeVectorStore = check new(pineConeServiceUrl, pineConeApiKey);
final ai:Wso2EmbeddingProvider aiEmbeddingProvider = check ai:getDefaultEmbeddingProvider();
final ai:VectorKnowledgeBase knowledgeBase = new(pineConeVectorStore, aiEmbeddingProvider);

final ai:Wso2ModelProvider defaultModel = check ai:getDefaultModelProvider();