import { PromiseValue } from "@mudkit/utils";
import { createHeadlessLayer } from "./createHeadlessLayer";

export type HeadlessLayer = PromiseValue<ReturnType<typeof createHeadlessLayer>>;
