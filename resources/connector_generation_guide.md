# Create your first connector with Ballerina

This guide walks you through creating your first Ballerina connector using an OpenAPI
specification.

## Introduction

Ballerina is a programming language that simplifies integration by providing a large
library of pre-built connectors. These connectors are special packages consisting of
one or more Ballerina clients, which allow communication with external services, usually
via REST APIs. By using connectors, developers can quickly integrate third-party
services into their Ballerina applications without having to worry about the technical
details of API interactions.
Along with its powerful library ecosystem, Ballerina also allows developers to easily
create, share, and manage client connectors. These connectors are typically published
on Ballerina Central as public connectors, available to the entire community, but you can
also publish them as private connectors for internal use within your organization.
In this guide, we'll walk you through how to generate your first Ballerina connector using
an OpenAPI specification. This is one of the fastest and easiest ways to build
connectors, enabling you to quickly integrate external services into your Ballerina
projects.

## Prerequisites

Before we begin, make sure you have:

1. A basic understanding of Ballerina Swan Lake and the latest version installed.

2. An OpenAPI specification of the API for which you’re building the connector,
    along with the relevant API credentials where required (e.g., Twitter Developer
    account keys).
3. A GitHub account, and Git installed locally.
4. Visual Studio Code with the Ballerina extension installed.

## Step 1: Set the project structure

Important: If you'd like to contribute your project as an official Ballerina connector, you
can skip the steps below and contact the Ballerina team through the Discord
community. In this case, the repository will be created under the ballerina-platform
organization, and the team will set up the initial project structure for you.

1. Create a new GitHub repository to host your connector. Ballerina official
    connector repositories follow the naming pattern:
    module-ballerinax-<connector-name> (e.g., module-ballerinax-twitter). But for
    other connectors, you can choose a name that best represents your connector.
2. Clone your newly created repository to your local machine:
```
git clone https://github.com/<your-username>/<connector-repo-name>.git
cd <connector-repo-name>
```
3. Visit the Ballerina generated connector template on GitHub and copy the entire
    project structure and content to your local repository folder, making sure to
    include all files and directories.
4. Your local project structure should now look similar to this:


```
module-ballerinax-myconnector/
├── .github/
├── ballerina/
| ├── tests/
│ ├── Ballerina.toml
│ ├── README.md
│ ├── build.gradle
│ └── client.bal
├── build-config/
├── docs/
│ └── spec/
│ └── sanitations.md
├── examples/
│ ├── README.md
│ ├── build.gradle
│ └── build.sh
├── gradle/
├── .gitignore
├── LICENSE
├── README.md
├── build.gradle
├── gradle.properties
├── gradlew
├── gradlew.bat
└── settings.gradle
```
Tip: The template includes placeholders for various fields. To update them with
your connector-specific metadata, use the provided Ballerina script.
Detailed information on the Ballerina connector structure can be found in the Ballerina
module contribution guide.

## Step 2: Prepare the OpenAPI definition

1. Find the OpenAPI definition for the API you want to create a connector. This is
    usually available in the API documentation. Example: For Twitter, you can get the
    latest API definition from the Twitter OpenAPI endpoint.
2. Save the file as openapi.yaml (or openapi.json) in the docs/spec directory of
    your project.
3. To improve compatibility and readability before generating the Ballerina client,
    run the following preprocessing steps using the Ballerina OpenAPI tool:

##### a. Flatten the OpenAPI definition

The primary purpose of the flattening command is to:
- **Enhance Readability** : By moving inline embedded schemas to the components
section, the OpenAPI definition becomes cleaner and easier to navigate.
- **Reduce Redundancy** : Inline schemas can lead to duplication of definitions.
Flattening helps eliminate this redundancy, ensuring that each schema is defined
only once.
```
$ bal openapi flatten -i docs/spec/openapi.yaml -o docs/spec
```
After executing the flattening command, you can expect the following changes in the
output file:
- All inline schemas will be moved to the components section of the OpenAPI
definition.
- References to these schemas will be updated to point to their new locations in
the components section.
- The overall structure of the OpenAPI definition will be more organized, making it
easier for developers to understand and work with.

##### b. Align the flattened OpenAPI definition

The aligning command is designed to refine the OpenAPI specification after it has been
flattened. This step is crucial for

- Align the OpenAPI definition according to the best practices of Ballerina
- Ensuring that the generated Ballerina types are consistent with Ballerina's naming
conventions.
```
$ bal openapi align -i docs/spec/flattened_openapi.yaml -o docs/spec
```
This command will generate a file named aligned_ballerina_openapi.yaml in the
docs/spec directory.
Next steps:
- Remove the original openapi.yaml and flattened_openapi.yaml from
the docs/spec directory.
- Rename aligned_ballerina_openapi.yaml to openapi.yaml.
- Use the new openapi.yaml for generating the Ballerina client in the Step 3.
Note:
- These preprocessing steps often reduce the need for manual sanitization.
However, if further changes are needed (e.g. modifying security schemes or
redefining schemas), document them in docs/spec/sanitations.md.
- You may need to perform additional sanitization after generating the client
code (Step 3) and testing the connector (Step 4) to address any
compile-time or runtime issues. Make sure to update the sanitations.md
file accordingly.

## Step 3: Generate the Ballerina client code

With your OpenAPI definition ready, use the Ballerina OpenAPI tool to generate the
connector code.

1. In your terminal, run the following command from the project root:


```
$ bal openapi -i docs/spec/openapi.yaml --mode client -o ballerina
```
2. This will generate the ballerina source code of the client connector in your
    ballerina/ directory.
Note: The Ballerina OpenAPI tool supports multiple customization options when
generating clients. For more details, check the Ballerina OpenAPI tool
documentation.
3. Make sure that the generated client implementation consists of the following
    files:
    - client.bal: Contains the client implementation with all the API operations.
    - types.bal: Contains the data types used in the client.
    - utils.bal: Contains utility functions used in the client.

##### Common Sanitation Steps for Ballerina Connector Generation

After generating the Ballerina client from an OpenAPI specification, you may encounter
several types of errors. This section provides detailed explanations of why these errors
occur and how to fix them based on real-world experience with the Smartsheet
connector.

**1. Resolving Redeclared Symbol Errors**
In the generated the types.bal file, you may encounter compilation errors like:
```
error: redeclared symbol 'action'
error: redeclared symbol 'additionalDetails'
error: redeclared symbol 'objectType'
```
This error occurs when multiple schemas in an allOf composition define the same
field names. This is common in event-based APIs where:
- A base Event schema defines common fields like action, additionalDetails,
objectType
- Specific event schemas (like DiscussionCreateAllOf2) also define these same
fields
- The Ballerina OpenAPI tool generates duplicate field definitions in the resulting
record type
**Example Problematic Schema**
```json
DiscussionCreate:
  allOf:
    - $ref: '#/components/schemas/Event'
    - $ref: '#/components/schemas/DiscussionCreateAllOf2'  # Contains duplicate fields
```
Both `Event` and `DiscussionCreateAllOf2` define action, additionalDetails,
and objectType, causing redeclared symbol errors.
**Solution Applied**
Replace the $ref to the conflicting schema with an inlined object definition containing
only the unique fields:
```json
DiscussionCreate:
  allOf:
    - $ref: '#/components/schemas/Event'
    - type: object
      properties:
        comment:
          type: string
          description: "Comment text"
        # Include only fields that don't conflict with Event schema
        # Remove: action, additionalDetails, objectType (already in Event)

```
**2. Fixing Missing Documentation Warnings**
You may see warnings like:
```
warning: undocumented field 'fieldName'
```
The Ballerina OpenAPI tool cannot properly extract field descriptions when they are:
- Placed alongside $ref declarations
- Located inside items objects for arrays
- Not structured according to Ballerina's expected format
- Even though descriptions exist in the OpenAPI spec, they're not recognized due
to formatting issues.

#### **Example Problems and Solutions**
##### Problem 1: Description alongside $ref  

```
# Problematic format
fieldName:
  $ref: '#/components/schemas/SomeType'
  description: "This description won't be recognized"

```
Solution:
```
# Fixed format
fieldName:
  allOf:
    - $ref: '#/components/schemas/SomeType'
  description: "This description will be recognized"
```
##### Problem 2: Description inside items for arrays
```
# Problematic format
fieldName:
  type: array
  items:
    $ref: '#/components/schemas/SomeType'
    description: "This will not work"

```
Solution:
```
# Fixed format
fieldName:
  type: array
  description: "Array of items description"
  items:
    $ref: '#/components/schemas/SomeType'

```
This sanitation ensures that the generated types.bal file includes proper documentation
comments for all fields, improving code readability and IDE support.  
**3. Renaming Auto-Generated Schema Names**
While generating the types.bal file using the Ballerina OpenAPI tool, several record
types were generated with generic names like:
``` 
InlineResponse
InlineResponse20070AllOf
InlineResponse
```
These names are unclear and make the generated code difficult to understand and
maintain.
The OpenAPI tool auto-generates schema names based on response codes when:
- The original OpenAPI spec is missing title fields in schema definitions
- Schemas are defined inline within responses rather than in the
components/schemas section
- The flattening process creates new schema names without meaningful titles
This leads to default names like InlineResponse200X where X is incremented for each
response. 

**Example Generated Code**
```
public type InlineResponse20070AllOf2 record {
    # List of Dashboards
    SightListItem[] data?;
};
```
**Solution Applied**
- **Manual Renaming** : Replaced generic schema names in the aligned OpenAPI
specification with meaningful, descriptive names
- **Reference Updates** : Updated all corresponding $ref entries throughout the spec
to match the new names  

**Examples of Meaningful Replacements:**

```
InlineResponse2007 → SharedSecretResponse
InlineResponse20010 → WebhookResponse
InlineResponse20012 → ContactListResponse
InlineResponse20070AllOf2 → DashboardListData
```
Github copilot was used to suggest possible names and then the suggestions were
extracted and applied manually to ensure correctness and consistency

### Step 4: Test the Connector

Now that your connector is generated, it is important to write tests to ensure everything
works as expected.
When testing, it is **mandatory** to include both:
- **Mock server based tests** – to guarantee that the connector is always testable
without requiring live credentials.
- **Live server based tests** – to validate the connector against the real API once
credentials (e.g., API keys, OAuth tokens) become available.  
You cannot rely on live server testing alone. Even if live credentials are not available at the time of development, the test suite must be designed so that it can run seamlessly against both environments.   
This ensures that:
    - the connector is always testable immediately using the mock server.
    - the same tests can later be executed against the live server without modification
once credentials are available.

#### 1. Decide on the Testing Approach


Every connector must be tested in **both environments** :
- **Mock server testing (mandatory)**
    - Ensures tests can run without depending on external accounts or
credentials.
    - If the connector has a small number of APIs, mock all available APIs.
    - If the connector has many APIs, mock the most frequently used or critical
ones.
- **Live server testing (mandatory)**
    - Validates connector behavior against the real service.
    - Requires developer account credentials (some services may only offer paid accounts).
    - Uses the same test suite as the mock server, switching only via configuration.

##### 2. Creating a Mock Server

Since every connector must support mock testing, you will need to generate and
implement a mock server:  

**Step 2.1: Generate a mock service**
Use the bal openapi command to generate a mock service for specific operations:
```
$ bal openapi -i <openapi_file>.yaml --mode service --operations <operation_id1>, <operation_id2>
```
The operation_id s can be found in the openapi specification.
(openapi.yaml/openapi.json)
Example:
```
$ bal openapi -i hello.yaml --mode service --operations getSheet,addRow
```
This generates a `mock_service.bal` file that includes service stubs for the selected
operations.

**Step 2.2: Implement the mock service**
Complete the generated service by returning mock responses for each operation.
See [`mock_service.bal`](https://github.com/ballerina-platform/module-ballerinax-smartsheet/blob/main/ballerina/tests/mock_service.bal) for an example.

##### 3. Writing Tests

Create your test cases inside the ballerina/tests directory.
- Add test cases for all critical connector operations.
- If you are using both live server and mock server testing, make sure your tests
are flexible enough to run in both modes.  

**Step 3.1: Configure test mode**  
To switch between **live server** and **mock server** , use a configurable variable in your test
```
configurable boolean isLiveServer = false;
configurable string serviceUrl = "";
```
- When `isLiveServer = true`, tests will run against the real service using
credentials.
- When `isLiveServer = false`, tests will run against the local mock server.  

**Step 3.2: Implement tests**
Write test cases in `test.bal` to validate API behavior.
Make sure your tests:
- Work with both live and mock servers.
- Validate success and error scenarios.
- Cover as many API use cases as possible.
Example test structure: [`test.bal`](https://github.com/ballerina-platform/module-ballerinax-smartsheet/blob/main/ballerina/tests/test.bal)

##### 4. Documenting Your Tests

Always document your testing approach in README.md inside the ballerina/tests
directory.
Your documentation should explain:

1. How to run tests against the **live server**.
2. How to run tests against the **mock server**.
3. Required configuration (e.g., credentials, environment variables).

Example: [Smartsheet connector tests README](https://github.com/ballerina-platform/module-ballerinax-smartsheet/blob/main/ballerina/tests/README.md)

##### 5. Running the Tests

Once your tests are ready, run them with:
```
$ bal test
```
This command executes all test cases in the ballerina/tests directory.
For detailed guidance on writing tests, check the [`Ballerina testing guide.`](https://ballerina.io/learn/test-ballerina-code/test-a-simple-function/)

## Step 5: Document the connector

Follow these steps to ensure your connector is well-documented:

**1. Update the ballerina/README.md file.**  
    This file will be displayed on the Ballerina Central package landing page. Make sure it provides a clear and comprehensive introduction to the connector, including the following sections:  
- **Overview:** Provide a concise introduction to the connector, explaining its purpose and key features.
- **Setup:** Offer step-by-step instructions on configuring the connector and
          any necessary prerequisites, such as API keys or environment setup.
- **Quickstart:** Include a basic and clear example that helps users to start
          using the connector immediately.
- **Examples** : Link to additional use cases, providing context on how the
          connector can be used in different scenarios.
For reference, check the [Twitter connector documentation](https://github.com/ballerina-platform/module-ballerinax-twitter/blob/main/ballerina/README.md).  

**2. Update the root level README.md file.**  
This file will be displayed on the GitHub repository landing page. Therefore, it
should include the same information as `ballerina/README.md` with a few
additional sections such as Building from Source, Contributing, License, etc.
For reference, check the [Twitter connector README](https://github.com/ballerina-platform/module-ballerinax-twitter/blob/main/README.md).


**3. Write example use cases.**

Providing practical examples helps users understand the connector better. These
examples should show how the connector is used in real-world scenarios.  
**Examples directory structure**  
All the examples should be added under the examples/ directory with the following structure:
```
examples/
├── README.md # Main examples documentation
├── build.gradle # Gradle build configuration for all examples
├── build.sh # Build script for Unix/Linux systems
├── example_name_1/ # Individual example directory
│ ├── Ballerina.toml # Package configuration
│ ├── Dependencies.toml # Dependencies (if any)
│ ├── main.bal # Main Ballerina source code
│ ├── build.sh # Example-specific build script
│ ├── build.bat # Windows build script
│ ├── build.gradle # Example-specific Gradle configuration
│ ├── Example Description.md # Detailed example documentation
│ └── .github/
│ └── README.md # GitHub-specific README (references main doc)
└── example_name_2/ # Additional examples...
└── ...
```
- Each example should be added as a Ballerina package with its own
README.md file, explaining the use case and how to run the example.
For reference, check the [Twitter connector examples](https://github.com/ballerina-platform/module-ballerinax-twitter/tree/main/examples).


