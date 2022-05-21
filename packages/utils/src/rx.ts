import {
  BehaviorSubject,
  delay,
  filter,
  first,
  mergeMap,
  Observable,
  of,
  OperatorFunction,
  pipe,
  scan,
  Timestamp,
  timestamp,
  UnaryFunction,
} from "rxjs";
import { computed, IComputedValue, observable, reaction, runInAction } from "mobx";
import { deferred } from "./deferred";

export function filterNullish<T>(): UnaryFunction<Observable<T | null | undefined>, Observable<T>> {
  return pipe(filter((x) => x != null) as OperatorFunction<T | null | undefined, T>);
}

/**
 * RxJS operator to stretch out an event stream by a given delay per event
 * @param spacingDelayMs Delay between each event in ms
 * @returns stream of events with at least spacingDelayMs spaceing between event
 */
export function stretch<T>(spacingDelayMs: number) {
  return pipe(
    timestamp<T>(),
    scan((acc: (Timestamp<T> & { delay: number }) | null, curr: Timestamp<T>) => {
      // calculate delay needed to offset next emission
      let delay = 0;
      if (acc !== null) {
        const timeDelta = curr.timestamp - acc.timestamp;
        delay = timeDelta > spacingDelayMs ? 0 : spacingDelayMs - timeDelta;
      }

      return {
        timestamp: curr.timestamp,
        delay: delay,
        value: curr.value,
      };
    }, null),
    filterNullish(),
    mergeMap((i) => of(i.value).pipe(delay(i.delay)), 1)
  );
}

export function computedToStream<T>(comp: IComputedValue<T>): Observable<T> {
  const stream = new BehaviorSubject(comp.get());
  reaction(
    () => comp.get(),
    (value) => stream.next(value)
  );
  return stream;
}

export function streamToComputed<T>(stream: Observable<T>): IComputedValue<T | undefined> {
  const value = observable<{ current: T | undefined }>({ current: undefined });
  stream.subscribe((val) => runInAction(() => (value.current = val)));
  return computed(() => value.current);
}

/**
 *
 * @param stream RxJS observable to check for the given value
 * @param predicate Predicate to check
 * @returns A promise that resolves with the requested value once the predicate is true
 */
export async function awaitStreamValue<T>(stream$: Observable<T>, predicate: (value: T) => boolean): Promise<T> {
  const [resolve, , promise] = deferred<T>();
  stream$.pipe(first(predicate)).subscribe(resolve);
  return promise;
}
