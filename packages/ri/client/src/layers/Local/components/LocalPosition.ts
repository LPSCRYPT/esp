import { World } from "@latticexyz/recs";
import { defineCoordComponent } from "@latticexyz/std-client";

export function defineLocalPositionComponent(world: World) {
  return defineCoordComponent(world, { id: "LocalPosition" });
}
