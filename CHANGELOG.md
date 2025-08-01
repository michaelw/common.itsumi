## [0.3.2](https://github.com/michaelw/common.itsumi/compare/v0.3.1...v0.3.2) (2025-08-01)


### Bug Fixes

* add support for custom restart policy in deployment template ([fbed4b8](https://github.com/michaelw/common.itsumi/commit/fbed4b80ed0077a69e485ce92eae5daec3a5563c))

## [0.3.1](https://github.com/michaelw/common.itsumi/compare/v0.3.0...v0.3.1) (2025-07-29)


### Bug Fixes

* add custom labels context to deployment, HPA, ingress, job, secret, and service templates ([48014b3](https://github.com/michaelw/common.itsumi/commit/48014b3f53877d5a689c5dc8cbf04d1a88bcd6ad))
* auto-generate namespaced volume references, with override option ([50ca465](https://github.com/michaelw/common.itsumi/commit/50ca4658e8462623d97d0f672589e4927e193975))
* update backendRefs name handling in GRPCRoute and HTTPRoute templates ([2876fa7](https://github.com/michaelw/common.itsumi/commit/2876fa7019ec926bd827ec14469f18bbb332f126))

# [0.3.0](https://github.com/michaelw/common.itsumi/compare/v0.2.4...v0.3.0) (2025-07-29)


### Features

* add support for sidecar initContainers ([fa6165c](https://github.com/michaelw/common.itsumi/commit/fa6165c5f971ec48a3e00684f8143fe6b41af99f))

## [0.2.4](https://github.com/michaelw/common.itsumi/compare/v0.2.3...v0.2.4) (2025-07-29)


### Bug Fixes

* correct variable reference in deployment template inclusion ([398af22](https://github.com/michaelw/common.itsumi/commit/398af2273089b48b1024e952ec1b282cd3daf177))

## [0.2.3](https://github.com/michaelw/common.itsumi/compare/v0.2.2...v0.2.3) (2025-07-29)


### Bug Fixes

* update mount name handling in job template ([af7bc70](https://github.com/michaelw/common.itsumi/commit/af7bc7090ea5cbdaccd258851ab1bb69aa1e8b5c))

## [0.2.2](https://github.com/michaelw/common.itsumi/compare/v0.2.1...v0.2.2) (2025-07-29)


### Bug Fixes

* set default name for mount in job template ([164b0ff](https://github.com/michaelw/common.itsumi/commit/164b0ff7c2e339e7ef6928ccda32d27ea8c14055))

## [0.2.1](https://github.com/michaelw/common.itsumi/compare/v0.2.0...v0.2.1) (2025-07-29)


### Bug Fixes

* standardize label handling in ConfigMap, Deployment, Job, and Secret templates ([346b91b](https://github.com/michaelw/common.itsumi/commit/346b91bc9e4906935ee2dc4f69cb3983abd1df45))

# [0.2.0](https://github.com/michaelw/common.itsumi/compare/v0.1.8...v0.2.0) (2025-07-28)


### Features

* update semantic release workflow and remove ORAS ([b5d5b7c](https://github.com/michaelw/common.itsumi/commit/b5d5b7ce6b6cbe606ecadee0a9f36a3057c7cd20))

## [0.1.8](https://github.com/michaelw/common.itsumi/compare/v0.1.7...v0.1.8) (2025-07-28)


### Bug Fixes

* correct release badge link in README.md ([5749731](https://github.com/michaelw/common.itsumi/commit/57497314c5f2d5b30045e271204b8bd972d8a99f))

## [0.1.7](https://github.com/michaelw/common.itsumi/compare/v0.1.6...v0.1.7) (2025-07-28)


### Bug Fixes

* Makefile ([9a5eef8](https://github.com/michaelw/common.itsumi/commit/9a5eef8dd77324d99a84817d3c0a6f00ec9c73e8))
* Makefile ([16f862d](https://github.com/michaelw/common.itsumi/commit/16f862dae9591af7f2b00bfbcc22a13de20fd285))
* trigger semantic release ([baae3e2](https://github.com/michaelw/common.itsumi/commit/baae3e2cfc8a6e419c87e0178efd14befe6227e9))

## [0.1.6](https://github.com/michaelw/common.itsumi/compare/v0.1.5...v0.1.6) (2025-07-28)


### Bug Fixes

* **broken docs:** helm template mustaches ([5031ddb](https://github.com/michaelw/common.itsumi/commit/5031ddb68cf4685b753069cb8be713e2b97bb3f1))

## [0.1.5](https://github.com/michaelw/common.itsumi/compare/v0.1.4...v0.1.5) (2025-07-28)


### Bug Fixes

* **release:** specify registry in chart push step for clarity ([3e29767](https://github.com/michaelw/common.itsumi/commit/3e29767e28f800f1f1eb7f444e2b717833e3da16))

## [0.1.3](https://github.com/michaelw/common.itsumi/compare/v0.1.2...v0.1.3) (2025-07-28)


### Bug Fixes

* **workflow:** update trigger to run on successful release completion ([d1d6ee3](https://github.com/michaelw/common.itsumi/commit/d1d6ee30e6914fda04a0f0a0ceb5663a7471770b))

## [0.1.1](https://github.com/michaelw/common.itsumi/compare/v0.1.0...v0.1.1) (2025-07-28)


### Bug Fixes

* **ci:** remove failing template step ([6659018](https://github.com/michaelw/common.itsumi/commit/66590189655d971019281422d58e27f3a91e70ad))
