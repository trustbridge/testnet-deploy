# Hamlet Trustbridge Provider

The hamlet Trustbridge provider is a set of established modules which implement different components in the trustbridge system. The module has been tested with AWS based deployments using the hamlet deployment framework.

Each application component is broken up into its own module allowing for users to pick and choose the implementations appropriate to them

## Modules

- channel_api - is a serverless deployment of the [API based Channel](https://github.com/trustbridge/api-channel) and consists of the components for a single jurisdiction deployment
- channel_shareddb - is a serverless deployment of the [Shared DB Testing Channel](shared-db-channel) and includes all the components to deploy a single jurisdction or instance. To deploy multiple jurisdictions invoke this module multiple times in the same solution with the `instance` id value unique for each instance
- intergov - is a serverless deployment of the [intergov document store](https://github.com/trustbridge/intergov) and contains all of the components required for single jurisdiction deployment

## Extensions

The core components of each module have a corresponding extension which handles the configuration required for those components
