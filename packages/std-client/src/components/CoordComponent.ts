import { defineComponent, Metadata, Type, World } from "@latticexyz/recs";

export function defineCoordComponent<M extends Metadata>(world: World, options?: { id?: string; metadata?: M }) {
  return defineComponent<{ x: Type.Number; y: Type.Number }, M>(world, { x: Type.Number, y: Type.Number }, options);
}
