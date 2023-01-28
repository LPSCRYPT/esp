# esp

The **E**xtensible **S**ignaling **P**rimitive is a framework for building modular _(consisting of subcomponents with well-defined interfaces and functions that can be consumed independently of each other)_ and composable _(the degree to which these subcomponents can be combined to form more complex systems)_ signaling systems. A signal is simply a data input which may result in changes to the state of the system being signalled. In this regard signaling systems operate as a state machine. In fact, a signaling system taking place within atomic blockchain transactions is a well defined state machine.

**esp** is a state management system designed for onchain signal processing. DAOs can use it to quickly implement new voting schemes, preference capture boards, treasury management applications, and proposal voting methods. **esp** leverages the robust MUD state management framework to compartmentalize signal inputs into discrete storage mappings in `components`, mutated by `systems`, the wiring together of which allows for anyone to modularly compose their own signal `Stream` easily and without needing to switch over to a new set of DAO tooling. Existing frameworks can be wrapped within signal `Streams`. **esp** is not _fully_ MUD compliant, the notable exception being that the `SignalRouterSystem` stores state. However, this may be changed in a future update.

The signal `Stream` is an abstraction built atop MUD which routes all incoming signals through a `SignalRouter`. `Streams` can be instantiated permisionlessly from the `StreamOwnerRegistry` and whitelist various `systems` which define the mutations which can occur to their inputs, and which `systems` are permissioned to update `component` state for that stream. Additionally, a MemberRegistrySystem (inherting from `BaseMemberRegistrySystem`) is defined for each signal `Stream` which determines user signalling permissions within a particular `Stream`. Designed with composability in mind, a MemberRegistrySystem may be deployed once and used for multiple streams.

This repo is currently an unaudited alpha build, while fit for testing do not build any funds-controlling systems without knowing what you are doing!

Relevant code for **esp** is in `/packages/solecs/src/esp-contracts`.

This repo is a fork of [MUD core](https://github.com/latticexyz/mud), and none of the code outside of `packages/solecs` is being used in the current implementation. However, the MUD framework has many tools which could be of use in future frontend and middleware integrations for **esp**.

 ![System Diagram](https://i.imgur.com/Ckg24iQ.png)
