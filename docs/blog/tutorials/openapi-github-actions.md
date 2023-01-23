---
tags:
    - Tutorial
    - OpenAPI
    - Github Actions
description: |
    How to build models from OpenAPI using Github Actions for CI/CD
image: https://avatars3.githubusercontent.com/u/16343502
---

# Generating Models from OpenAPI with Github Actions

## What is OpenAPI?

![OpenAPI Banner](https://www.openapis.org/wp-content/uploads/sites/3/2018/02/OpenAPI_Logo_Pantone-1.png){width="300" align=right loading=lazy}

[OpenAPI](https://www.openapis.org/) specification files make it much easy for developers to communicate how to interact with an API in a standardized way. OpenAPI is used by many technology companies, including Microsoft, Google, and SalesForce[^1]. OpenAPI files are either YAML or JSON files that define the endpoints and model the data for an HTTP API.

Below are a few snippets from an example definition:

### POST Definition
This snippet defines a POST operation to create a new pet.
```yaml
{{format_text(retrieve_example('openapi-generator/definition.yaml'),60,69,0)}}
```

### GET Definition with path parameter
This snippet defines a GET operation allowing the user to fetch a Pet by ID
```yaml
{{format_text(retrieve_example('openapi-generator/definition.yaml'),83,94,0)}}
```

### Pet Schema
This snippet defines the shape of the 'Pet' object
```yaml
{{format_text(retrieve_example('openapi-generator/definition.yaml'),128,139,0)}}
```

## Autogeneration

![Pet Store](https://s3.us-west-1.wasabisys.com/idbwmedia.com/images/api/swagger_editor_pic.png){width="300"  align=right loading=lazy}

Once created, the definition file can be used to generate various types of files. The example to the right shows a Swagger[^2] HTML visualization that many developers will be familiar with. The clean, minimal YAML is automatically transformed into attractive, hostable HTML documentation.

Various tools exist for these kinds of transformations, in this example, we will focus on the ['OpenAPI Generator'](https://github.com/OpenAPITools/openapi-generator) project. This is a Java tool that can be used to generate docs, API clients, and server stubs. This example will focus on API client generation.

In this case, instead of managing the Java package installation, it is simpler to use the NPM CLI provided to execute relevant commands. This can be installed by the following command:

```
npm install @openapitools/openapi-generator-cli -g
```

Alternatively, we can use the `npx` command to run the cli without worrying about the installation. We can now pass the path to our definition and the language we would like to generate to the CLI


```bash
npx @openapitools/openapi-generator-cli generate -g python -i /path/to/my/definition.yaml -o output
```

!!! warning Incomplete
    Article is incomplete. Check back soon!


[^1]: [See current members of the OpenAPI Initiative](https://www.openapis.org/membership/members)
[^2]: [Article explaining 'Swagger' vs. 'OpenAPI'](https://swagger.io/blog/api-strategy/difference-between-swagger-and-openapi/)
