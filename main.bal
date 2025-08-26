import ballerina/ai;
import ballerina/io;

public function main() returns error? {
    string guide = check io:fileReadString("resources/connector_generation_guide.md");
    ai:TextDocument doc = {content: guide};
    ai:Chunk[] chunk = check ai:chunkDocumentRecursively(doc);
    check knowledgeBase.ingest(chunk);
    io:println("Ingestion completed.");
}
