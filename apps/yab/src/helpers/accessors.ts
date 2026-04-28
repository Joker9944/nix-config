import { Accessor } from "ags"
import { lazy } from "./lazy"

export function lazyAccessor<T>(factory: () => Accessor<T>): Accessor<T> {
	let get = lazy(factory)
	return new Accessor<T>(
		() => get().peek(),
		(callback) => get().subscribe(callback),
	)
}
