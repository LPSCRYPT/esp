# esp

The **E**xtensible **S**ignaling **P**rimitive is a framework for building modular *(consisting of subcomponents with well-defined interfaces and functions that can be consumed independently of each other)* and composable *(the degree to which these subcomponents can be combined to form more complex systems)* signaling systems. A signal is simply a data input which may result in changes to the state of the system being signalled. In this regard signaling systems operate as a state machine. In fact, a signaling system taking place within atomic blockchain transactions is a well defined state machine.

**esp** is a state management system designed for onchain signal processing. DAOs can use it to quickly implement new voting schemes, treasury management applications, and proposal voting. **esp** leverages the robust MUD state management framework to compartmentalize signal inputs into discrete storage mappings in `components`, mutated by `systems`, the wiring together of which allows for anyone to modularly compose their own signal `Stream` easily and without needing to switch over to a new set of DAO tooling. Existing frameworks can be wrapped within signal `Streams`.

The signal `Stream` is an abstraction built atop MUD which routes all incoming signals through a `SignalRouter`. `Streams` can be instantiated permisionlessly and whitelist various `systems` which define the mutations which will occur to their inputs. Additionally, a `UserRegistry` is defined for each signal `Stream` which determines who is allowed to signal within a particular `Stream`. 

Relevant code for **esp** is in `/packages/solecs/src/esp-contracts`. 

---
icon: public/logo512.png
---

# MUD

<div align="center">
<img src="public/logo512.png" width="200" style="margin: 0 0 30px 0;" alt="MUD logo" />
<p>MUD - Engine for Autonomous Worlds</p>
</div>

<p align="center">
  <a aria-label="license MIT" href="https://opensource.org/licenses/MIT">
    <img alt="" src="https://img.shields.io/badge/License-MIT-yellow.svg">
  </a>
  &nbsp;
  <a aria-label="test status" href="https://github.com/latticexyz/mud/actions/workflows/test.yml">
    <img alt="" src="https://github.com/latticexyz/mud/actions/workflows/test.yml/badge.svg?branch=main&event=push">
  </a>
  &nbsp;
  <a aria-label="docs status" href="https://github.com/latticexyz/mud/actions/workflows/docs.yml">
    <img alt="" src="https://github.com/latticexyz/mud/actions/workflows/docs.yml/badge.svg?branch=main&event=push">
  </a>
</p>

MUD is a framework for complex Ethereum applications.

It adds some conventions for organizing data and logic and abstracts away low-level complexities so you can focus on the features of your app.

It standardizes the way data is stored on-chain.
With this standard data model, MUD can provide all network code to synchronize contract and client state. This includes synchronizing state directly from an RPC node or a general-purpose MUD indexer.

MUD is MIT-licensed, open source and free to use.

## Features

![MUD features](/public/features.png)

### Today

- State synchronization between contracts and clients without custom networking code
- General purpose indexers (without custom indexing code)
- Seamless contract upgrades (+ automatic contract upgrades during development)
- Shared contract state
- Optimistic updates
- Automatic type generation for contracts and systems
- Query language to interact with contract state
- Data explorer to inspect and modify contract and local state
- Bitpacking utilities

### Soon

- Local simulation of transactions (including optimistic state)
- Built-in support for account abstraction
- Contract package manager

## Quickstart

```
npx mud create my-project
```

![Scaffolding a new project with the MUD CLI.](/public/mud-create.gif)

## Packages

MUD consists of several libraries. They can be used independently, but are best used together.

| Package                                                                                                                   | Version                                                                                                                               |
| ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| **[@latticexyz/solecs](/packages/solecs)** <br />Solidity Entity Component System library                                 | [![npm version](https://img.shields.io/npm/v/@latticexyz/solecs.svg)](https://www.npmjs.org/package/@latticexyz/solecs)               |
| **[@latticexyz/network](/packages/network)** <br />TypeScript networking library for automatic contract/client state sync | [![npm version](https://img.shields.io/npm/v/@latticexyz/network.svg)](https://www.npmjs.org/package/@latticexyz/network)             |
| **[@latticexyz/recs](/packages/recs)** <br />TypeScript Reactive Entity Component System library                          | [![npm version](https://img.shields.io/npm/v/@latticexyz/recs.svg)](https://www.npmjs.org/package/@latticexyz/recs)                   |
| **[@latticexyz/services](/packages/services)** <br />Go services for indexer, faucet, message relay                       | [![npm version](https://img.shields.io/npm/v/@latticexyz/services.svg)](https://www.npmjs.org/package/@latticexyz/services)           |
| **[@latticexyz/cli](/packages/cli)** <br />Command line interface for types, testing, faucet, deployment and more         | [![npm version](https://img.shields.io/npm/v/@latticexyz/cli.svg)](https://www.npmjs.org/package/@latticexyz/cli)                     |
| **[@latticexyz/std-contracts](/packages/std-contracts)** <br />Solidity standard library                                  | [![npm version](https://img.shields.io/npm/v/@latticexyz/std-contracts.svg)](https://www.npmjs.org/package/@latticexyz/std-contracts) |
| **[@latticexyz/std-client](/packages/std-client)** <br />Typescript standard library                                      | [![npm version](https://img.shields.io/npm/v/@latticexyz/std-client.svg)](https://www.npmjs.org/package/@latticexyz/std-client)       |
| **[@latticexyz/noise](/packages/noise)** <br />Solidity and AssemblyScript implementations of Perlin noise                | [![npm version](https://img.shields.io/npm/v/@latticexyz/noise.svg)](https://www.npmjs.org/package/@latticexyz/noise)                 |

## Contribute

We'd love your support in improving MUD! This monorepo includes all of MUD's source code, and pull requests are always welcome. To discuss new features or changes [join our Discord](https://discord.com/invite/XhZp6HbqNp).

### Local development setup

!!!
The following steps are only necessary if you want to contribute to MUD. To use MUD in your project, install the [packages](#packages) from npm or [set up a new project with the MUD cli](#quickstart).
!!!

1. Install go (required to build [packages/services](packages/services/)): [https://go.dev/doc/install](https://go.dev/doc/install)

2. Install the foundry toolkit (required to build and test MUD solidity packages): [https://getfoundry.sh/](https://getfoundry.sh/)

3. Clone the MUD monorepo

```
git clone https://github.com/latticexyz/mud
```

4. Install MUD dependencies and setup local environment

```
cd mud && yarn
```

### Pull requests

MUD follows the [conventional commit specification](https://www.conventionalcommits.org/en/v1.0.0/) for commit messages and PR titles. Please keep the scope of your PR small (rather open multiple small PRs than one huge PR) and follow the conventional commit spec.

## Library

[!embed](https://www.youtube.com/embed/j-_Zf8o5Wlo)
[!embed](https://www.youtube.com/embed/mv3jA4USZtg)

## Community support

[Join our Discord](https://discord.com/invite/XhZp6HbqNp) to get support and connect with the community!

## License

MUD is open-source software [licensed as MIT](LICENSE).
