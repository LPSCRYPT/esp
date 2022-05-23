import { defineComponent, Type, World } from "@mudkit/recs";

export function defineMoveSpeedComponent(world: World) {
  return defineComponent(world, { default: Type.Number, current: Type.Number }, { name: "MoveSpeed" });
}
